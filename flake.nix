{
  description = "Reusable NixOS user configurations";
  outputs =
    { nixpkgs, self }@inputs:
    let
      import_modules = import ./resources/nix/import_modules.nix;
    in
    {
      inputs = inputs;
      nixosModules.default = {
        imports = import_modules ./users;
      };
    };
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=25.11";
    };
  };
}
