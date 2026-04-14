{ pkgs, ... }:
{
  config.programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      anthropic.claude-code
      continue.continue
      jnoortheen.nix-ide
      vscodevim.vim
      github.copilot-chat
      platformio.platformio-vscode-ide
      ms-vscode.cpptools-extension-pack
      ms-vscode.cpptools
    ];
  };
}
