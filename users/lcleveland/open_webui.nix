{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    services.open-webui = {
      enable = true;
    };
  };
}
