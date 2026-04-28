{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    services = {
      printing = {
        enable = true;
        drivers = [
          pkgs.hplipWithPlugin
        ];
      };
      avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
      system-config-printer = {
        enable = true;
      };
    };
  };
}
