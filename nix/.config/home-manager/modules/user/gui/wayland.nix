{pkgs, ...}: {
  home.sessionVariables = {};
  home.packages = with pkgs; [
    fnott # wayland notifications
    fuzzel # wayland launcher
    grim # to take screenshots
    swww # wallpaper daemon for wayland
    tofi # an extremely fast and simple dmenu / rofi replacement for wlroots-based Wayland compositors
    wdisplays # gui for configuring displays in Wayland compositors
    wev # xev for wayland
    wlr-randr # xrandr for wayland
    wtype # xdotool for wayland
    ydotool # xdotool systemwide
  ];
  services.hyprpaper.enable = true;
  programs.hyprlock.enable = true;
}
