{ pkgs, lib, ... }:
{
  config.programs.vscode = {
    enable = true;
    package = pkgs.vscode.overrideAttrs (old: {
      postFixup = (old.postFixup or "") + ''
        wrapProgram $out/bin/code --add-flags "--password-store=gnome-libsecret"
      '';
    });
    extensions =
      (with pkgs.vscode-extensions; [
        continue.continue
        jnoortheen.nix-ide
        vscodevim.vim
        github.copilot-chat
        platformio.platformio-vscode-ide
        ms-vscode.cpptools-extension-pack
        ms-vscode.cpptools
      ])
      ++ [
        (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "claude-code";
            publisher = "anthropic";
            version = "latest";
            hash = "sha256-08j98EQj0b9LZqy25dGWF17xEb+/tIioABb4atu1SjY=";
          };
          postInstall = ''
            mkdir -p "$out/$installPrefix/resources/native-binary"
            rm -f "$out/$installPrefix/resources/native-binary/claude"*
            ln -s "${pkgs.claude-code}/bin/claude" "$out/$installPrefix/resources/native-binary/claude"
          '';
        })
      ];
  };
}
