{ config, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      khal = prev.khal.overrideAttrs (old: {
        doCheck = false;
        doInstallCheck = false;
        dontUseSphinx = true;
      });
    })
  ];
}
