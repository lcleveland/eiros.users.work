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
        (pkgs.vscode-extensions.anthropic.claude-code.override {
          src = pkgs.fetchurl {
            url = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/anthropic/vsextensions/claude-code/latest/vspackage";
            sha256 = "0djanpdnmy0n02l8id5zpw8z2phpjv8ybdmccr5vzl938kqgvj6k";
          };
        })
      ];
  };
}
