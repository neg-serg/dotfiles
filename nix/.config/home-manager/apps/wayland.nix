{ pkgs, lib, ... }: {
    home.sessionVariables = {};
    home.packages = with pkgs; [
        fnott # wayland notifications
        fuzzel # wayland launcher
        swww # wallpaper daemon for wayland
        wtype # xdotool for wayland
        ydotool # xdotool systemwide
    ];

    wayland.windowManager.sway = {
        enable = true;
        extraOptions = [];
        config = {
            modifier = "Mod4";
            terminal = "kitty"; # Use kitty as default terminal
            startup = [
                # # Launch Firefox on start
                # {command = "firefox";}
            ];
            # Samsung Electric Company Odyssey G85SB H1AK500000
            input = {
	      "*" = {
                xkb_layout = "us,ru";
                xkb_options = "grp:alt_shift_toggle";

              };
              "type:keyboard" = {
                  repeat_delay = "250";
                  repeat_rate = "60";
              };
	    };
	    output = {
               "*" = {
                    mode = "3440x1440@174.962Hz";
                    adaptive_sync = "on";
                    bg = lib.mkForce "~/pic/wl/wallhaven-49pqxk.jpg fill";
	    };	    
        };
    };
  };
}

# bindsym Mod4+Return exec kitty
# bindsym Mod1+grave exec ~/bin/rofi-run
# 
# systemd.user.services.wpaperd = {
#     Unit = {
#         Description = "Wallpaper daemon";
#         After = ["graphical-session-pre.target"];
#         PartOf = ["graphical-session.target"];
#     };
#     Service = {
#         ExecStart = "${pkgs.wpaperd}/bin/wpaperd --no-daemon";
#         Environment = "XDG_CONFIG_HOME=${wpaperd-config-dir}";
#     };
#     Install.WantedBy = ["graphical-session.target"];
# };

# programs = {
#     gamescope = {
#         enable = true;
#         capSysNice = true;
#         args = [ "--steam"
#                 "--expose-wayland"
#                 "--rt"
#                 "-W 1920"
#                 "-H 1080"
#                 "--force-grab-cursor"
#                 "--grab"
#                 "--fullscreen"
#         ];
#     };
# }
