{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = {
    # PC/SC daemon. The NixOS pcscd module loads pkgs.ccid as a plugin by
    # default, which is the driver the OMNIKEY 5427 G2 uses in CCID mode.
    services.pcscd.enable = true;

    environment.systemPackages = [
      pkgs.pcsc-tools # pcsc_scan: detect the reader and read card UIDs
      pkgs.opensc # opensc-tool / PKCS#11 middleware (general smartcard use)
    ];
  };
}
