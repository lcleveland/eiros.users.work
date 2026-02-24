{ config, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      khal = prev.khal.overrideAttrs (_: {
        dontUseSphinx = true;
      });
    })
  ];
}
