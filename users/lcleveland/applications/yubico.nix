{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    services.pcscd.enable = true;
    environment.systemPackages = [
      pkgs.yubioath-flutter
    ];
  };
}
