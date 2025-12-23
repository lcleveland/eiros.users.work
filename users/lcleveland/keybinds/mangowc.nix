{ config, lib, ... }:
let
  eiros_dms = config.eiros.system.desktop_environment.dank_material_shell.enable;
in
{
  config.eiros.users.lcleveland = {
    mangowc = {
      keybinds = {
        launch_spotlight = lib.mkIf config.eiros.system.desktop_environment.dank_material_shell.enable {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "d";
          mangowc_command = "spawn_shell";
          command_arguments = "dms ipc call spotlight toggle";
        };
        close_window = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "q";
          mangowc_command = "killclient";
        };
        quit_mangowc = {
          modifier_keys = [
            "SUPER"
            "SHIFT"
          ];
          flag_modifiers = [ "s" ];
          key_symbol = "q";
          mangowc_command = "quit";
        };
        launch_file_browser = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "f";
          mangowc_command = "spawn";
          command_arguments = "ghostty -e yazi";
        };
        launch_terminal = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "t";
          mangowc_command = "spawn";
          command_arguments = "ghostty";
        };
        switch_focus_left = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "h";
          mangowc_command = "focusdir";
          command_arguments = "left";
        };
        switch_focus_right = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "l";
          mangowc_command = "focusdir";
          command_arguments = "right";
        };
        switch_focus_up = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "k";
          mangowc_command = "focusdir";
          command_arguments = "up";
        };
        switch_focus_down = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "j";
          mangowc_command = "focusdir";
          command_arguments = "down";
        };
        swap_window_left = {
          modifier_keys = [
            "SUPER"
            "SHIFT"
          ];
          flag_modifiers = [ "s" ];
          key_symbol = "h";
          mangowc_command = "exchange_client";
          command_arguments = "left";
        };
        swap_window_right = {
          modifier_keys = [
            "SUPER"
            "SHIFT"
          ];
          flag_modifiers = [ "s" ];
          key_symbol = "l";
          mangowc_command = "exchange_client";
          command_arguments = "right";
        };
        swap_window_up = {
          modifier_keys = [
            "SUPER"
            "SHIFT"
          ];
          flag_modifiers = [ "s" ];
          key_symbol = "k";
          mangowc_command = "exchange_client";
          command_arguments = "up";
        };
        swap_window_down = {
          modifier_keys = [
            "SUPER"
            "SHIFT"
          ];
          flag_modifiers = [ "s" ];
          key_symbol = "j";
          mangowc_command = "exchange_client";
          command_arguments = "down";
        };
        window_toggle_float = {
          flag_modifiers = [ "s" ];
          modifier_keys = [ "SUPER" ];
          key_symbol = "g";
          mangowc_command = "togglefloating";
        };
        window_toggle_maximize = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "m";
          mangowc_command = "togglemaximizescreen";
        };
        overview_toggle = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "Tab";
          mangowc_command = "toggleoverview";
        };
        reload_configuration = {
          modifier_keys = [
            "SUPER"
            "SHIFT"
          ];
          flag_modifiers = [ "s" ];
          key_symbol = "r";
          mangowc_command = "reload_config";
        };
        lock_screen = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "Escape";
          mangowc_command = "spawn_shell";
          command_arguments = "dms ipc call lock lock";
        };
        night_mode_toggle = {
          modifier_keys = [ "SUPER" ];
          flag_modifiers = [ "s" ];
          key_symbol = "n";
          mangowc_command = "spawn_shell";
          command_arguments = "dms ipc call night toggle";
        };
      };
    };
  };
}
