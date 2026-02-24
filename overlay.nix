{ ... }:
{
  nixpkgs.overlays = [
    (import ./nix/khal.nix)
  ];
}
