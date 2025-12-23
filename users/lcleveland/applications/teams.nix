{
  config,
  lib,
  pkgs,
  ...
}:
{
  config.environment.systemPackages = [
    pkgs.teams-for-linux
  ];
}
