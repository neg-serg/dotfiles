{pkgs, inputs, hy3, ...}: {
  home.sessionVariables = {};
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
        source = [
            "/home/neg/.config/hypr/init.conf"
        ];
        permission = [
          "${pkgs.grim}/bin/grim, screencopy, allow"
        ];
    };
    plugins = [ hy3.packages.x86_64-linux.hy3 ];
    systemd.variables = ["--all"];
  };
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
    fuzzel # wayland launcher
    grim # to take screenshots
    matugen # modern theme generator
    slurp # select region in wayland compositor
    swww # wallpaper daemon for wayland
    tofi # an extremely fast and simple dmenu / rofi replacement for wlroots-based Wayland compositors
    waybar # simple titlebar for wayland
    wdisplays # gui for configuring displays in Wayland compositors
    wev # xev for wayland
    wf-recorder # tool to make screencasts
    wl-clipboard # copy-paste for wayland
    wtype # xdotool for wayland
    ydotool # xdotool systemwide
  ];
  programs.hyprlock.enable = true;
}
