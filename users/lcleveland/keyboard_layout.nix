{ config, lib, ... }:
{
  config = {
    eiros.system.hardware.keyboard.variant = "colemak_dh";
    eiros.users.lcleveland.mangowc.settings = {
      xkb_rules_layout = "us";
      xkb_rules_variant = "colemak_dh";
    };
  };
}
