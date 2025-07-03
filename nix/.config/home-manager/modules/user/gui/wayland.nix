{pkgs, inputs, ...}: {
  home.sessionVariables = {};
  imports = [ inputs.ags.homeManagerModules.default ];
  programs.ags = {
    enable = true;
    configDir = null;
    extraPackages = [
      inputs.ags.packages.${pkgs.system}.apps
      inputs.ags.packages.${pkgs.system}.battery
      inputs.ags.packages.${pkgs.system}.bluetooth
      inputs.ags.packages.${pkgs.system}.hyprland
      inputs.ags.packages.${pkgs.system}.io
      inputs.ags.packages.${pkgs.system}.mpris
      inputs.ags.packages.${pkgs.system}.network
      inputs.ags.packages.${pkgs.system}.notifd
      inputs.ags.packages.${pkgs.system}.powerprofiles
      inputs.ags.packages.${pkgs.system}.tray
      inputs.ags.packages.${pkgs.system}.wireplumber
    ];
  };
  home.packages = with pkgs; [
    clipse # yet another clipboard manager
    fuzzel # wayland launcher
    gowall # tool to convert a Wallpaper's color scheme / palette
    grim # to take screenshots
    inputs.astal.packages.${system}.default # astal library support
    inputs.iwmenu.packages.${pkgs.system}.default # wifi menu
    satty # screenshot helper tool
    slurp # select region in wayland compositor
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
