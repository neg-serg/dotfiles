{
  lib,
  config,
  pkgs,
  hy3,
  ...
}:
with lib; let
  hy3Plugin = hy3.packages.${pkgs.system}.hy3;
in
  mkIf config.features.gui {
    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      settings = {
        source = [
          "${config.xdg.configHome}/hypr/init.conf"
        ];
        permission = [
          "${hy3Plugin}/lib/libhy3.so, plugin, allow"
          "${pkgs.grim}/bin/grim, screencopy, allow"
          "${pkgs.hyprlock}/bin/hyprlock, screencopy, allow"
        ];
      };
      plugins = [
        hy3Plugin
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
      kdePackages.qt6ct # Qt6 config tool
      pyprland # Hyprland plugin system
      upower # power management daemon
    ];
    programs.hyprlock.enable = true;
  }
