{pkgs, inputs, ...}:
with {
  fabric-ui = pkgs.callPackage ../../../packages/fabric {};
}; {
  home.sessionVariables = {};
  imports = [ inputs.ags.homeManagerModules.default ];
  programs.ags = {
    enable = true;
    configDir = null;
    extraPackages = [
      inputs.ags.packages.${pkgs.system}.notifd
      inputs.ags.packages.${pkgs.system}.battery
      inputs.ags.packages.${pkgs.system}.io
    ];
  };
  home.packages = with pkgs; [
    clipse # yet another clipboard manager
    fabric-ui # python-based ui library
    fuzzel # wayland launcher
    grim # to take screenshots
    inputs.iwmenu.packages.${pkgs.system}.default # wifi menu
    satty # screenshot helper tool
    slurp # select region in wayland compositor
    swayimg # wayland-native image viewer
    swaynotificationcenter # try another notification center
    swww # wallpaper daemon for wayland
    tofi # an extremely fast and simple dmenu / rofi replacement for wlroots-based Wayland compositors
    waybar # install temporary
    wev # xev for wayland
    wf-recorder # tool to make screencasts
    wl-clipboard # copy-paste for wayland
    wtype # typing for wayland
    ydotool # xdotool systemwide
  ];
  programs.hyprlock.enable = true;
}
