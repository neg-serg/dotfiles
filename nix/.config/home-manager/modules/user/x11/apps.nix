{
  pkgs,
  config,
  negwmPkg,
  stable,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
  i3-get-window-criteria = pkgs.callPackage ../../../packages/i3-get-window-criteria {};
  i3-lock-fancy-rapid = pkgs.callPackage ../../../packages/i3lock-fancy-rapid {};
  i3-balance-workspace = pkgs.callPackage ../../../packages/i3-balance-workspace {};
  alluvium = pkgs.callPackage ../../../packages/alluvium {};
}; {
  imports = [./dunst.nix];
  home.packages = with pkgs; [
    # alluvium # show i3 bindings
    flameshot # interactive screenshot tool
    herbe # notification without daemon and dbus
    hsetroot # set x11 root image
    i3-balance-workspace # TRY: balance workspaces
    i3-get-window-criteria # xwindowinfo (test)
    i3lock-fancy-rapid # TRY: better lock
    i3 # my favorite wm
    stable.maim # screenshot tool for x11
    negwmPkg.negwm # my own i3 helper
    polybar # my favorite panel so far
    xdragon # drag and drop from console
  ];
  services.sxhkd = {
    enable = false;
    keybindings = {};
  };
  xdg.configFile = {
    "polybar" = {
      source = l "${dots}/wm/.config/polybar";
      recursive = true;
    };
  };
  home.file = {
    ".local/bin/polybar-run" = {
      executable = true;
      text = ''
        #!/bin/sh
        killall -KILL polybar
        if [ "$(hostname)" != 'telfir' ]; then
            POLYBAR_DPI="$(echo "$1/1.85" | bc)"
        else
            POLYBAR_DPI=65
        fi
        export POLYBAR_DPI
        systemctl --user import-environment POLYBAR_DPI
        polybar main -l error
      '';
    };
  };
}
