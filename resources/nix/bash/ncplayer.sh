#!/usr/bin/env bash
set -euo pipefail

# ===== Config =====
DBX_NAME="${DBX_NAME:-ncplayer}"
DBX_IMAGE="${DBX_IMAGE:-archlinux:latest}"

DESKTOP_NAME="${DESKTOP_NAME:-ninjarmm-ncplayer.desktop}"
DESKTOP_DIR="${DESKTOP_DIR:-$HOME/.local/share/applications}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
HANDLER="${HANDLER:-$BIN_DIR/ninjarmm-handler}"

# Runtime deps for ncplayer
ARCH_PKGS=(
  libxdamage libxfixes libxext libxrender libx11 libxcb
  libxrandr libxinerama libxcursor libxi libxtst
  libxkbcommon-x11
  xcb-util-cursor xcb-util-wm xcb-util-keysyms xcb-util-renderutil
  mesa libglvnd libdrm
  libpulse
  fontconfig freetype2 ttf-dejavu
)

log() { printf "\n\033[1m==>\033[0m %s\n" "$*"; }
die() { printf "\n\033[1;31mERROR:\033[0m %s\n" "$*" >&2; exit 1; }

command -v distrobox >/dev/null || die "distrobox missing"
command -v xdg-mime  >/dev/null || die "xdg-mime missing"
command -v systemctl >/dev/null || die "systemctl missing"

mkdir -p "$DESKTOP_DIR" "$BIN_DIR"

dbx() {
  # run a command inside the container (non-interactive)
  distrobox-enter -n "$DBX_NAME" -- bash -lc "$*"
}

wait_for() {
  local desc="$1"
  local cmd="$2"
  local tries="${3:-120}"
  local sleep_s="${4:-1}"

  for _ in $(seq 1 "$tries"); do
    if eval "$cmd" >/dev/null 2>&1; then
      return 0
    fi
    sleep "$sleep_s"
  done
  die "Timed out waiting for: $desc"
}

wait_for_pacman_ready() {
  # check lock and active pacman processes *inside* the container
  wait_for "pacman to be ready (no lock/pacman-key)" \
    "dbx \"! test -e /var/lib/pacman/db.lck && ! pgrep -x pacman >/dev/null 2>&1 && ! pgrep -x pacman-key >/dev/null 2>&1\"" \
    240 1
}

# ===== Ensure container exists =====
log "Ensuring distrobox container exists: $DBX_NAME ($DBX_IMAGE)"
if ! distrobox ls --no-color 2>/dev/null | awk '{print $2}' | grep -qx "$DBX_NAME"; then
  distrobox-create --yes --name "$DBX_NAME" --image "$DBX_IMAGE"
else
  log "Container already exists"
fi

log "Waiting for distrobox-enter to work..."
wait_for "distrobox-enter" "distrobox-enter -n '$DBX_NAME' -- bash -lc 'true'"

log "Waiting for pacman readiness..."
wait_for_pacman_ready

# ===== Bootstrap inside container (distrobox way) =====

log "Installing base tools (requires sudo inside container)"
dbx "command -v sudo >/dev/null 2>&1 || echo 'WARNING: sudo not found inside container; installs may fail.'"

# NOTE: These installs require privileges inside the container.
# We intentionally do NOT use podman nor distrobox --root. Only sudo within container.
dbx "sudo pacman -Syu --noconfirm --needed base-devel git"

wait_for_pacman_ready

log "Installing paru (AUR) as normal user"
dbx '
  if ! command -v paru >/dev/null 2>&1; then
    rm -rf /tmp/paru
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
  fi
'

wait_for_pacman_ready

log "Installing ncplayer runtime deps (repo) via paru"
dbx "paru -Syu --noconfirm --needed ${ARCH_PKGS[*]}"

wait_for_pacman_ready

log "Installing ninjarmm-ncplayer (AUR) via paru"
dbx "paru -S --noconfirm --needed ninjarmm-ncplayer"

# ===== Host integration =====
log "Writing handler: $HANDLER"
cat > "$HANDLER" <<EOF
#!/usr/bin/env bash
set -euo pipefail

unset LD_LIBRARY_PATH LD_PRELOAD NIX_LD NIX_LD_LIBRARY_PATH
export QT_QPA_PLATFORM=xcb
export GDK_BACKEND=x11

exec distrobox-enter -n "${DBX_NAME}" -- /opt/ncplayer/bin/ncplayer -u "\$@"
EOF
chmod +x "$HANDLER"

log "Writing desktop file: $DESKTOP_DIR/$DESKTOP_NAME"
cat > "$DESKTOP_DIR/$DESKTOP_NAME" <<EOF
[Desktop Entry]
Type=Application
Name=NinjaOne Remote (ncplayer)
Exec=$HANDLER %U
Terminal=false
Categories=Network;RemoteAccess;
MimeType=x-scheme-handler/ninjarmm;
EOF

log "Registering URL handler"
xdg-mime default "$DESKTOP_NAME" x-scheme-handler/ninjarmm
update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
systemctl --user try-restart xdg-desktop-portal.service >/dev/null 2>&1 || true

log "Done."
echo "Test with:"
echo "  xdg-open 'ninjarmm://test'"

