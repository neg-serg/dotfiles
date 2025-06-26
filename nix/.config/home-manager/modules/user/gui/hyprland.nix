{pkgs, hy3, inputs, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    settings = {
        source = [
            "/home/neg/.config/hypr/init.conf"
        ];
        permission = [
          "${hy3.packages.x86_64-linux.hy3}/lib/libhy3.so, plugin, allow"
          "${pkgs.grim}/bin/grim, screencopy, allow"
          "${pkgs.hyprlandPlugins.hyprbars}/lib/libhyprbars.so, plugin, allow"
          "${pkgs.hyprlock}/bin/hyprlock, screencopy, allow"
        ];
    };
    plugins = [ 
        hy3.packages.x86_64-linux.hy3 
        pkgs.hyprlandPlugins.hyprbars
    ];
    systemd.variables = ["--all"];
  };
  home.packages = with pkgs; [
    hyprcursor # is a new cursor theme format that has many advantages over the widely used xcursor.
    hypridle # idle daemon
    hyprland-qt-support # qt support
    hyprland-qtutils # utility apps for hyprland
    hyprpicker # color picker
    hyprpolkitagent # better polkit agent
    hyprprop # xrop for hyprland
    hyprutils # small library for hyprland
    inputs.quickshell.packages.${pkgs.system}.default
    kdePackages.kdialog
    kdePackages.qt5compat # needed for Qt5Compat modules in Qt6
    kdePackages.qt6ct
    kdePackages.qtdeclarative # Qt6
    kdePackages.qtimageformats
    kdePackages.qtmultimedia
    kdePackages.qtpositioning
    kdePackages.qtquicktimeline
    kdePackages.qtsensors
    kdePackages.qtsvg
    kdePackages.qttools
    kdePackages.qttranslations
    kdePackages.qtvirtualkeyboard
    kdePackages.qtwayland
    pyprland # hyperland plugin system
    upower
  ];
  programs.hyprlock.enable = true;
}
