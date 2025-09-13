{
  pkgs,
  lib,
  config,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
    home.packages = with pkgs; config.lib.neg.pkgsList [
      fastfetch # modern, fast system fetch
      onefetch # repository summary in terminal
    ];
  }
  (xdg.mkXdgText "fastfetch/skull" ''
                          :::!~!!!!!:.
                      .xUHWH!! !!?M88WHX:.
                    .X*#M@$!!  !X!M$$$$$$WWx:.
                   :!!!!!!?H! :!$!$$$$$$$$$$8X:
                  !!~  ~:~!! :~!$!#$$$$$$$$$$8X:
                 :!~::!H!<   ~.U$X!?R$$$$$$$$MM!
                 ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!
                   !:~~~ .:!M"T#$$$$WX??#MRRMMM!
                   ~?WuxiW*`   `"#$$$$8!!!!??!!!
                 :X- M$$$$       `"T#$T~!8$WUXU~
                :%`  ~#$$$m:        ~!~ ?$$$$$$
              :!`.-   ~T$$$$8xx.  .xWW- ~""##*"
    .....   -~~:<` !    ~?T#$$@@W@*?$$      /`
    W$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :
    #"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`
    :::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~
    .~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `
    Wi.~!X$?!-~    : ?$$$B$Wu("**$RM!
    $R@i.~~ !     :   ~$$$$$B$$en:``
    ?MXT@Wx.~    :     ~"##*$$$$M~
  '')
  (xdg.mkXdgText "fastfetch/config.jsonc" (builtins.toJSON {
    "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
    logo = {
      source = "~/.config/fastfetch/skull";
      width = 65;
      padding = {
        left = 1;
        right = 3;
      };
    };
    display = {
      separator = " ";
      size = {maxPrefix = "TB";};
      percent = {type = 1;};
      color = {
        output = "01;38;5;248";
        keys = "38;5;24;1";
      };
    };
    modules = [
      {
        type = "os";
        key = "󱄅";
        format = "{3}";
      }
      {
        type = "kernel";
        key = "";
        format = "{1} {2} ({4})";
      }
      {
        type = "uptime";
        key = "";
      }
      {
        type = "wm";
        key = "";
      }
      {
        type = "command";
        key = "󰆧";
        text = "(${lib.getExe' pkgs.nix "nix-store"} --query --requisites /run/current-system | wc -l | tr -d '\n') && echo ' (nix; /run/current-system)'";
      }
      {
        type = "host";
        key = "🖥";
      }
      {
        type = "monitor";
        key = "";
      }
      {
        type = "theme";
        key = "";
      }
      {
        type = "icons";
        key = "";
      }
      {
        type = "cursor";
        key = "";
      }
      {
        type = "shell";
        key = "︁";
      }
      {
        type = "terminal";
        key = "︁";
      }
      {
        type = "terminalfont";
        key = "︁";
      }
      {
        type = "cpu";
        key = "";
      }
      {
        type = "memory";
        key = "󰍛";
      }
      {
        type = "board";
        key = "";
      }
      {
        type = "bios";
        key = "";
      }
      {
        type = "gpu";
        driverSpecific = true;
        key = "";
      }
      {
        type = "vulkan";
        key = "";
      }
      {
        type = "disk";
        key = "";
      }
      {
        type = "sound";
        key = "";
      }
      {
        type = "player";
        key = "";
      }
      {
        type = "users";
        key = "";
      }
      {
        type = "locale";
        key = "";
      }
      {
        type = "weather";
        key = "";
      }
    ];
  }))
]
