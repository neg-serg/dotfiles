{pkgs, inputs, ...}: {
  home.sessionVariables = {};
  home.packages = with pkgs; [
    clipse # yet another clipboard manager
    fuzzel # wayland launcher
    gowall # tool to convert a Wallpaper's color scheme / palette
    grimblast # hyprland screenshot tool
    grim # to take screenshots
    inputs.iwmenu.packages.${pkgs.system}.default # wifi menu
    slurp # select region in wayland compositor
    swww # wallpaper daemon for wayland
    waybar # install temporary
    waypipe # proxy for wayland similar to ssh -X
    wev # xev for wayland
    wf-recorder # tool to make screencasts
    wl-clipboard # copy-paste for wayland
    wl-clip-persist # clipboard persistence tool
    wtype # typing for wayland
    ydotool # xdotool systemwide
  ];
  programs.hyprlock.enable = true;
}
