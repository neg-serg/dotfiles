{pkgs, ...}: {
  home.sessionVariables = {};
  home.packages = with pkgs; [
    fnott # wayland notifications
    fuzzel # wayland launcher
    swayfx # i3 for wayland
    swww # wallpaper daemon for wayland
    wdisplays # gui for configuring displays in Wayland compositors
    wofi # rofi for wayland
    wpaperd # wallpaper daemon for wayland
    wtype # xdotool for wayland
    ydotool # xdotool systemwide
  ];
  services.hyprpaper.enable = true;
  programs.hyprlock.enable = true;
}
