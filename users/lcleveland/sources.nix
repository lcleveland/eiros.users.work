{ lib, ... }:
{
  config.eiros.system.nix.sources.users.url = lib.mkForce "github:lcleveland/eiros.users.work";
}
