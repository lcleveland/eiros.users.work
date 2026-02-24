{ ... }:
{
  nixpkgs.overlays = [
    (import ./resources/nix/khal.nix)
  ];
}
