{ lib, ... }:
{
  config.eiros.system.nix.sources.users.url = lib.mkDefault "github:lcleveland/eiros.users.work";
}
