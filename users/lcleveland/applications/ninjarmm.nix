{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.eiros.system.virtualization.distrobox.ninjarmm;

  virt_enabled =
    (config.eiros.system.virtualization.enable or false)
    && (config.eiros.system.virtualization.podman.enable or false);

  arch_deps = [
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

  arch_deps_str = lib.concatStringsSep " " arch_deps;
in
{
  options.eiros.system.virtualization.distrobox.ninjarmm = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable NinjaRMM ncplayer support via a distrobox container.";
    };

    container_name = lib.mkOption {
      type = lib.types.str;
      default = "ncplayer";
      description = "Name of the distrobox container hosting Ninja ncplayer.";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "archlinux:latest";
      description = "OCI image used when creating the distrobox container.";
    };

    install_ncplayer = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install ninjarmm-ncplayer inside the container via paru.";
    };
  };

  config = lib.mkIf (cfg.enable && virt_enabled) {
    # Optional but helpful: fail fast if parents are "enabled" but distrobox isn't actually present.
    assertions = [
      {
        assertion = pkgs ? distrobox;
        message = "ninjarmm distrobox support requires pkgs.distrobox to be available (handled by parent modules).";
      }
    ];

    systemd.user.services."distrobox-${cfg.container_name}-ninjarmm-ensure" = {
      description = "Ensure NinjaRMM distrobox exists and is bootstrapped";
      wantedBy = [ "default.target" ];
      after = [ "graphical-session.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = [
          # Give scripts a sane PATH for basic shell tooling inside the service
          "PATH=/run/current-system/sw/bin:/usr/bin:/bin"
        ];
      };

      script = ''
        set -euo pipefail

        name="${cfg.container_name}"
        image="${cfg.image}"

        # Create container if missing
        if ! ${pkgs.distrobox}/bin/distrobox-list --no-color | awk '{print $1}' | grep -qx "$name"; then
          ${pkgs.distrobox}/bin/distrobox-create \
            --yes \
            --name "$name" \
            --image "$image"
        fi

        # Bootstrap paru + install runtime deps
        ${pkgs.distrobox}/bin/distrobox-enter -n "$name" -- bash -lc '
          set -euo pipefail

          if ! command -v paru >/dev/null 2>&1; then
            sudo pacman -Syu --noconfirm --needed base-devel git
            tmpdir="$(mktemp -d)"
            cd "$tmpdir"
            git clone https://aur.archlinux.org/paru.git
            cd paru
            makepkg -si --noconfirm
          fi

          sudo paru -Syu --noconfirm --needed ${arch_deps_str}

          ${lib.optionalString cfg.install_ncplayer ''
            sudo paru -S --noconfirm --needed ninjarmm-ncplayer
          ''}
        '
      '';
    };
  };
}
