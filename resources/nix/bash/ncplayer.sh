#!/usr/bin/env bash
set -euo pipefail

# ===== Config (override via env vars) =====
DBX_NAME="${DBX_NAME:-ncplayer}"
DBX_IMAGE="${DBX_IMAGE:-archlinux:latest}"

DESKTOP_NAME="${DESKTOP_NAME:-ninjarmm-ncplayer.desktop}"
DESKTOP_DIR="${DESKTOP_DIR:-$HOME/.local/share/applications}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
HANDLER="${HANDLER:-$BIN_DIR/ninjarmm-handler}"

# Required Arch packages for ncplayer runtime
ARCH_PKGS=(
  libx11 libxcb libxext libxrender libxdamage libxfixes
  libxrandr libxinerama libxcursor libxi libxtst
  xcb-util-cursor xcb-util-wm
  libxkbcommon-x11
  mesa libglvnd libdrm
  libpulse
  fontconfig freetype2 ttf-dejavu
)

log() { printf "\n\033[1m==>\033[0m %s\n" "$*"; }
die() { printf "\n\033[1;31mERROR:\033[0m %s\n" "$*" >&2; exit 1; }

need() {
  command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"
}

# ===== Preflight =====
need distrobox
need xdg-mime
need systemctl

mkdir -p "$DESKTOP_DIR" "$BIN_DIR"

log "Ensuring distrobox container exists: $DBX_NAME ($DBX_IMAGE)"
if ! distrobox-list --no-color | awk '{print $1}' | grep -qx "$DBX_NAME"; then
  distrobox-create --yes --name "$DBX_NAME" --image "$DBX_IMAGE"
else
  log "Container already exists"
fi

log "Installing build prerequisites in container (root)"
distrobox-enter -n "$DBX_NAME" --root -- bash -lc \
  'set -euo pipefail; pacman -Syu --noconfirm --needed base-devel git'

log "Bootstrapping paru if missing"
if ! distrobox-enter -n "$DBX_NAME" -- bash -lc 'command -v paru >/dev/null 2>&1'; then
  distrobox-enter -n "$DBX_NAME" -- bash -lc '
    set -euo pipefail
    work="$(mktemp -d)"
    cd "$work"
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -sf --noconfirm
    echo "$work/paru" > /tmp/paru-build-dir.txt
  '

  distrobox-enter -n "$DBX_NAME" --root -- bash -lc '
    set -euo pipefail
    build_dir="$(cat /tmp/paru-build-dir.txt)"
    pkg="$(ls -1 "$build_dir"/paru-*.pkg.tar.* | head -n 1)"
    pacman -U --noconfirm "$pkg"
  '
else
  log "paru already installed"
fi

log "Installing ncplayer runtime deps"
distrobox-enter -n "$DBX_NAME" --root -- bash -lc "
  set -euo pipefail
  export PARU_EDITOR=/bin/true
  export EDITOR=/bin/true
  export PAGER=cat
  paru -Syu --noconfirm --needed ${ARCH_PKGS[*]}
"

log "Installing ninjarmm-ncplayer"
distrobox-enter -n "$DBX_NAME" --root -- bash -lc '
  set -euo pipefail
  export PARU_EDITOR=/bin/true
  export EDITOR=/bin/true
  export PAGER=cat
  paru -S --noconfirm --needed ninjarmm-ncplayer
'

log "Writing host handler: $HANDLER"
cat > "$HANDLER" <<EOF
#!/usr/bin/env bash
set -euo pipefail

unset LD_LIBRARY_PATH LD_PRELOAD NIX_LD NIX_LD_LIBRARY_PATH
export QT_QPA_PLATFORM=xcb
export GDK_BACKEND=x11
export PATH="/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:\$HOME/.local/bin"

exec distrobox-enter -n "${DBX_NAME}" -- /opt/ncplayer/bin/ncplayer -u "\$@"
EOF
chmod +x "$HANDLER"

log "Writing desktop entry"
cat > "$DESKTOP_DIR/$DESKTOP_NAME" <<EOF
[Desktop Entry]
Type=Application
Name=NinjaOne Remote (Distrobox)
Comment=Launch Ninja ncplayer inside distrobox (${DBX_NAME})
Exec=${HANDLER} %U
Terminal=false
Categories=Network;RemoteAccess;
MimeType=x-scheme-handler/ninjarmm;
EOF

log "Registering MIME handler"
xdg-mime default "$DESKTOP_NAME" x-scheme-handler/ninjarmm
update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
systemctl --user try-restart xdg-desktop-portal.service >/dev/null 2>&1 || true

log "Done."
echo "Test with: xdg-open 'ninjarmm://test'"
