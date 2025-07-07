{pkgs, inputs, ...}: {
  home.sessionVariables = {};
  home.packages = with pkgs; [
    clipse # yet another clipboard manager
    fuzzel # wayland launcher
    gowall # tool to convert a Wallpaper's color scheme / palette
    grim # to take screenshots
    inputs.iwmenu.packages.${pkgs.system}.default # wifi menu
    satty # screenshot helper tool
    slurp # select region in wayland compositor
    swww # wallpaper daemon for wayland
    tofi # an extremely fast and simple dmenu / rofi replacement for wlroots-based Wayland compositors
    waybar # install temporary
    waypipe # proxy for wayland similar to ssh -X
    wev # xev for wayland
    wf-recorder # tool to make screencasts
    wl-clipboard # copy-paste for wayland
    wtype # typing for wayland
    ydotool # xdotool systemwide
  ];
  programs.hyprlock.enable = true;
}
