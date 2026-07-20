{ pkgs, ... }:
let
  version = "14.35.8480";

  src = pkgs.fetchurl {
    url = "https://resources.ninjarmm.com/development/ninjacontrol/${version}/ninjarmm-ncplayer-${version}_x86_64.rpm";
    hash = "sha256-3AOFu8U47MTHUM9pyio6ruJf5ywBmQadB6fVS+zjf7E=";
  };

  # Extract the single self-contained binary from the RPM.
  ncplayer-bin = pkgs.stdenv.mkDerivation {
    pname = "ninjarmm-ncplayer-bin";
    inherit version src;
    nativeBuildInputs = [ pkgs.rpmextract ];
    unpackPhase = "rpmextract ${src}";
    installPhase = ''
      install -Dm755 opt/ncplayer/bin/ncplayer $out/bin/ncplayer
    '';
  };

  # Wrap in an FHS environment to satisfy the binary's runtime library deps.
  ncplayer = pkgs.buildFHSEnv {
    name = "ncplayer";
    targetPkgs =
      pkgs: with pkgs; [
        libdrm
        libgbm
        mesa
        dbus
        stdenv.cc.cc.lib
      ];
    runScript = pkgs.writeShellScript "ncplayer-run" ''
      export QT_QPA_PLATFORM=xcb
      exec ${ncplayer-bin}/bin/ncplayer "$@"
    '';
  };

  # Desktop entry registering the ninjarmm:// URL scheme so the portal can
  # launch remote sessions. Exec=ncplayer resolves to the FHS wrapper on PATH.
  ncplayer-desktop = pkgs.writeTextFile {
    name = "ninjarmm-ncplayer-desktop";
    destination = "/share/applications/ninjarmm-ncplayer.desktop";
    text = ''
      [Desktop Entry]
      Type=Application
      Name=NinjaOne Remote Player
      Exec=ncplayer %u
      StartupNotify=false
      MimeType=x-scheme-handler/ninjarmm;
    '';
  };
in
{
  config = {
    environment.systemPackages = [
      ncplayer
      ncplayer-desktop
    ];

    xdg.mime.defaultApplications."x-scheme-handler/ninjarmm" = "ninjarmm-ncplayer.desktop";
  };
}
