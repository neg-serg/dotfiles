{pkgs, ...}: {
  home.sessionVariables = {};
  home.packages = with pkgs; [
    fnott # wayland notifications
    fuzzel # wayland launcher
    grim # to take screenshots
    hyprcursor # is a new cursor theme format that has many advantages over the widely used xcursor.
    hypridle # idle daemon
    hyprland-qt-support # qt support
    hyprland-qtutils # utility apps for hyprland
    hyprpaper # setup wallpaper
    hyprpicker # color picker
    hyprpolkitagent # better polkit agent
    hyprsysteminfo # show system info
    hyprutils # small library for hyprland
    libsForQt5.qt5ct kdePackages.qt6ct # qt integration stuff
    pyprland # hyperland plugin system
    slurp # select region in wayland compositor
    swww # wallpaper daemon for wayland
    tofi # an extremely fast and simple dmenu / rofi replacement for wlroots-based Wayland compositors
    wdisplays # gui for configuring displays in Wayland compositors
    wev # xev for wayland
    wf-recorder # tool to make screencasts
    wl-clipboard # copy-paste for wayland
    wlr-randr # xrandr for wayland
    wtype # xdotool for wayland
    ydotool # xdotool systemwide
  ];
  services.hyprpaper.enable = true;
  programs.hyprlock.enable = true;
}
