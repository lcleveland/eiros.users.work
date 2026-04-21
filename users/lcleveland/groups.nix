{ lib, ... }:
{
  config.eiros.users.lcleveland.extra_groups = lib.mkDefault [
    "wheel"
    "networkmanager"
    "libvirtd"
    "docker"
    "input"
    "comfyui"
  ];
}
