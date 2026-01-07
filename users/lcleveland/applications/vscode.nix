{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Wrap VS Code so it can dlopen libsecret on NixOS (no FHS needed),
  # allowing OS keyring (org.freedesktop.secrets) to be detected.
  vscodeKeyringWrapped = pkgs.symlinkJoin {
    name = "vscode-keyring-wrapped";
    paths = [ pkgs.vscode ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram "$out/bin/code" \
        --set ELECTRON_KEYRING gnome \
        --add-flags "--password-store=gnome-libsecret" \
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            pkgs.libsecret
            pkgs.glib
            pkgs.dbus
            pkgs.nss
            pkgs.nspr
          ]
        }"
    '';
  };
in
{
  config.programs.vscode = {
    enable = true;

    # Use the wrapped VS Code binary so keyring integration works.
    package = vscodeKeyringWrapped;

    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      vscodevim.vim
      github.copilot
      github.copilot-chat
    ];
  };
}
