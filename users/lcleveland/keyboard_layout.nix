{ config, lib, ... }:
{
  config = {
    eiros.system.hardware.keyboard.variant = "colemak_dh";
    eiros.system.desktop_environment.dank_material_shell.greeter.hyprland.sections.input = {
      kb_layout = "us";
      kb_variant = "colemak_dh";
    };
    eiros.users.lcleveland.mangowc.settings = {
      xkb_rules_layout = "us";
      xkb_rules_variant = "colemak_dh";
    };
  };
}
