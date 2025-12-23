{ config, lib, ... }:
{
  config = {
    eiros.system.hardware.keyboard.variant = "colemak_dh";
    eiros.system.desktop_environment.dank_material_shell.greeter.hyprland.input = {
      kb_layout = "us";
      kb_variant = "colemak_dh";
    };
  };
}
