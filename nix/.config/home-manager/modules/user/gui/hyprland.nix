{pkgs, hy3, ...}: {
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
          "${pkgs.hyprlock}/bin/hyprlock, screencopy, allow"
          "${hy3.packages.x86_64-linux.hy3}, plugin, allow"
        ];
    };
    plugins = [ hy3.packages.x86_64-linux.hy3 ];
    systemd.variables = ["--all"];
  };
  home.packages = with pkgs; [
    hyprcursor # is a new cursor theme format that has many advantages over the widely used xcursor.
    hypridle # idle daemon
    hyprland-qt-support # qt support
    hyprland-qtutils # utility apps for hyprland
    hyprpanel # nice panel for hyprland
    hyprpicker # color picker
    hyprpolkitagent # better polkit agent
    hyprprop # xrop for hyprland
    hyprutils # small library for hyprland
    libsForQt5.qt5ct kdePackages.qt6ct # qt integration stuff
    pyprland # hyperland plugin system
  ];
  programs.hyprlock.enable = true;
}
