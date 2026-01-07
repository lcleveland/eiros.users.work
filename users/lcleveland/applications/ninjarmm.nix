{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.eiros.system.ninjarmm;

  # Arch packages required for Ninja ncplayer runtime inside the container
  ncplayerDeps = [
    "libx11"
    "libxcb"
    "libxext"
    "libxrender"
    "libxdamage"
    "libxfixes"
    "libxrandr"
    "libxinerama"
    "libxcursor"
    "libxi"
    "libxtst"
    "xcb-util-cursor"
    "xcb-util-wm"
    "libxkbcommon-x11"
    "mesa"
    "libglvnd"
    "libdrm"
    "libpulse"
    "fontconfig"
    "freetype2"
    "ttf-dejavu"
  ];
  ncplayerDepsArgs = lib.concatStringsSep " " ncplayerDeps;

  desktopFileName = "${cfg.desktop_entry_name}.desktop";
in
{
  options.eiros.system.ninjarmm = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Enable NinjaOne ncplayer integration via distrobox + ninjarmm:// handler.";
    };

    container_name = lib.mkOption {
      default = "arch";
      type = lib.types.str;
      description = "Distrobox container name that contains /opt/ncplayer.";
    };

    image = lib.mkOption {
      default = "archlinux:latest";
      type = lib.types.str;
      description = "Container image used to create the distrobox.";
    };

    install_ncplayer = lib.mkOption {
      default = true;
      type = lib.types.bool;
      description = "Install ninjarmm-ncplayer inside the distrobox container via paru.";
    };

    desktop_entry_name = lib.mkOption {
      default = "ninjarmm-ncplayer-distrobox";
      type = lib.types.str;
      description = "Desktop entry basename (without .desktop) used as the ninjarmm:// handler.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Host requirements for distrobox
    virtualisation.podman.enable = true;

    environment.systemPackages = [
      pkgs.distrobox
      pkgs.podman

      # Protocol handler installed on the host (declarative)
      (pkgs.writeShellScriptBin "ninjarmm-handler" ''
        set -euo pipefail

        # Prevent NixOS linker env from poisoning container runtime
        unset LD_LIBRARY_PATH LD_PRELOAD NIX_LD NIX_LD_LIBRARY_PATH

        # Force X11 backend (ncplayer only has Qt "xcb" plugin in container)
        export QT_QPA_PLATFORM=xcb
        export GDK_BACKEND=x11

        # Ensure distrobox/podman/coreutils are discoverable when launched from desktop
        export PATH="/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin:$HOME/.local/bin"

        exec ${pkgs.distrobox}/bin/distrobox-enter \
          -n ${lib.escapeShellArg cfg.container_name} \
          -- /opt/ncplayer/bin/ncplayer -u "$@"
      '')
    ];

    # Install a system-wide desktop file in /etc/xdg/applications/
    environment.etc."xdg/applications/${desktopFileName}".text = ''
      [Desktop Entry]
      Type=Application
      Name=NinjaOne Remote (Distrobox)
      GenericName=Remote Access
      Comment=Launch Ninja ncplayer inside the distrobox container
      Exec=ninjarmm-handler %U
      Terminal=false
      Categories=Network;RemoteAccess;
      MimeType=x-scheme-handler/ninjarmm;
    '';

    # Make ninjarmm:// open our handler
    xdg.mime.defaultApplications = {
      "x-scheme-handler/ninjarmm" = lib.mkForce [ desktopFileName ];
    };

    # Ensure the container exists + is bootstrapped (user service, non-interactive)
    systemd.user.services."distrobox-${cfg.container_name}-ensure" = {
      description = "Ensure distrobox ${cfg.container_name} exists and is bootstrapped for Ninja ncplayer";
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        # Restart portal so scheme handler changes are picked up automatically
        ExecStartPost = "${pkgs.systemd}/bin/systemctl --user try-restart xdg-desktop-portal.service";

        Environment = [
          "PATH=/run/current-system/sw/bin:/usr/local/bin:/usr/bin:/bin"
        ];
      };

      script = ''
        set -euo pipefail

        name=${lib.escapeShellArg cfg.container_name}
        image=${lib.escapeShellArg cfg.image}

        # Create container if missing
        if ! ${pkgs.distrobox}/bin/distrobox-list --no-color | awk '{print $1}' | grep -qx "$name"; then
          ${pkgs.distrobox}/bin/distrobox-create --yes --name "$name" --image "$image"
        fi

        # 1) Install build prerequisites as ROOT (no sudo/tty)
        ${pkgs.distrobox}/bin/distrobox-enter -n "$name" --root -- bash -lc '
          set -euo pipefail
          pacman -Syu --noconfirm --needed base-devel git
        '

        # 2) Build paru as USER (no sudo), only if missing
        ${pkgs.distrobox}/bin/distrobox-enter -n "$name" -- bash -lc '
          set -euo pipefail
          if command -v paru >/dev/null 2>&1; then
            exit 0
          fi

          work="$(mktemp -d)"
          cd "$work"
          git clone https://aur.archlinux.org/paru.git
          cd paru
          makepkg -sf --noconfirm
          echo "$work/paru" > /tmp/paru-build-dir.txt
        '

        # 3) Install the built paru package as ROOT
        ${pkgs.distrobox}/bin/distrobox-enter -n "$name" --root -- bash -lc '
          set -euo pipefail
          build_dir="$(cat /tmp/paru-build-dir.txt)"
          pkg="$(ls -1 "$build_dir"/paru-*.pkg.tar.* | head -n 1)"
          pacman -U --noconfirm "$pkg"
        '

        # 4) Install ncplayer runtime deps
        ${pkgs.distrobox}/bin/distrobox-enter -n "$name" --root -- bash -lc '
          set -euo pipefail
          export PARU_EDITOR=/bin/true
          export EDITOR=/bin/true
          export PAGER=cat
          paru -Syu --noconfirm --needed ${ncplayerDepsArgs}
        '

        # 5) Optionally install ninjarmm-ncplayer itself
        ${lib.optionalString cfg.install_ncplayer ''
          ${pkgs.distrobox}/bin/distrobox-enter -n "$name" --root -- bash -lc '
            set -euo pipefail
            export PARU_EDITOR=/bin/true
            export EDITOR=/bin/true
            export PAGER=cat
            paru -S --noconfirm --needed ninjarmm-ncplayer
          '
        ''}
      '';
    };
  };
}
