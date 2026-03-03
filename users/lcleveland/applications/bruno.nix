{
  config,
  lib,
  pkgs,
  ...
}:
{
  config.environment.systemPackages = [
    pkgs.bruno
    pkgs.bruno-cli
  ];
}
