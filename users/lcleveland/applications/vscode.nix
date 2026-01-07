{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Wrap the real pkgs.vscode derivation so it still has passthru attrs
  # like `executableName` that vscode-with-extensions requires.
  vscodeKeyringWrapped = pkgs.vscode.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

    postFixup = (old.postFixup or "") + ''
      if [ -x "$out/bin/code" ]; then
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
      fi
    '';
  });
in
{
  config.programs.vscode = {
    enable = true;

    # This preserves executableName/longName for vscode-with-extensions
    package = vscodeKeyringWrapped;

    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      vscodevim.vim
      github.copilot
      github.copilot-chat
    ];
  };
}
