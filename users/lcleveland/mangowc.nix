{ config, lib, ... }:
{
  config.eiros.users.lcleveland.mangowc.settings = {
    enable_hotarea = 0;
    ov_tab_mode = 1;
    idleinhibit_ignore_visible = 1;
    edge_scroller_pointer_focus = 0;
    trackpad_natural_scrolling = 1;
    gesturebind = [
      "none,left,3,focusdir,right"
      "none,right,3,focusdir,left"
      "none,up,3,focusdir,down"
      "none,down,3,focusdir,up"
    ];

    tagrule = [
      "id:1,monitor_name:eDP-1,layout_name:scroller"
      "id:1,monitor_name:DP-10,layout_name:scroller"
      "id:1,monitor_name:DP-11,layout_name:scroller"
    ];

    env = [
      "GTK_THEME,Adwaita:dark"
    ];
  };
}
