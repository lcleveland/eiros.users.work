{ config, lib, ... }:
{
  config.eiros.users.lcleveland.mangowc.settings = {
    enable_hotarea = 0;
    ov_tab_mode = 1;
    idleinhibit_ignore_visible = 1;
    edge_scroller_pointer_focus = 0;

    tagrule = [
      "tag:*,layout:scroller"
    ];

    env = [
      "GTK_THEME,Adwaita:dark"
    ];
  };
}
