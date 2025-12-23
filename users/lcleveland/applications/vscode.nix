{
  config,
  lib,
  pkgs,
  ...
}:
{
  config.programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      vscodevim.vim
      github.copilot
      github.copilot-chat
    ];
  };
}
