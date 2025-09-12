{
  lib,
  pkgs,
  config,
  ...
}: let
  browserRec = import ../web/default-browser-lib.nix {inherit lib pkgs config;};
in {
  services.dunst = {
    enable = true;
    iconTheme = {
      name = "kora";
      package = pkgs.kora-icon-theme;
    };
    settings = {
      global = {
        alignment = "left";
        browser = "${browserRec.bin} ${browserRec.newTabArg}";
        corner_radius = 4;
        ellipsize = "end";
        follow = "mouse";
        font = lib.mkForce "Iosevka Medium 10";
        format = "<span font_desc='Iosevka Medium 10' foreground='#2e72ac'>%s</span>\\n%b";
        frame_color = "#000000";
        frame_width = 10;
        gap_size = 4;
        height = "(0, 350)";
        hide_duplicate_count = true;
        horizontal_padding = 6;
        icon_position = "left";
        idle_threshold = 0;
        ignore_dbusclose = false;
        ignore_newline = false;
        indicate_hidden = true;
        line_height = 0;
        markup = "full";
        max_icon_size = 250;
        monitor = 0;
        notification_limit = 2;
        offset = "(0,54)";
        origin = "bottom-right";
        padding = 0;
        progress_bar = true;
        progress_bar_frame_width = 1;
        progress_bar_height = 6;
        progress_bar_max_width = 300;
        progress_bar_min_width = 150;
        scale = 0;
        separator_color = "frame";
        separator_height = 4;
        show_age_threshold = -1;
        show_indicators = false;
        sort = true;
        stack_duplicates = true;
        sticky_history = true;
        transparency = 14;
        vertical_alignment = "center";
        width = "(800, 1120)";
        word_wrap = false;
      };

      urgency_low = {
        background = "#010204";
        foreground = "#BFCAD0";
        timeout = 4;
      };

      urgency_normal = {
        background = "#000000";
        foreground = "#BFCAD0";
      };

      urgency_critical = {
        background = "#010204";
        foreground = "#BFCAD0";
        timeout = 0;
      };

      pic = {
        appname = "screenshot";
        format = "%s\\n%b";
        script = "~/bin/pic-notify";
        urgency = "normal";
      };

      telegram = {
        appname = "Telegram Desktop";
        word_wrap = true;
      };
    };
  };
}
