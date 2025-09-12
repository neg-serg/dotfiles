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
  mkIf config.features.gui.enable {
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
    # Live-editable Hyprland configuration (out-of-store symlinks to repo files)
    # Remove stale ~/.config/hypr symlink from older generations before linking
    home.activation.fixHyprConfigDir =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/hypr";
    xdg.configFile = {
      "hypr/init.conf" = config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/init.conf" false;
      "hypr/rules.conf" = config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/rules.conf" false;
      "hypr/bindings.conf" = config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/bindings.conf" false;
      "hypr/autostart.conf" = config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/autostart.conf" false;
      "hypr/workspaces.conf" = config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/workspaces.conf" false;
      "hypr/pyprland.toml" = config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/pyprland.toml" false;
    };
    home.packages = config.lib.neg.filterByExclude (with pkgs; [
      hyprcursor # modern cursor theme format (replaces xcursor)
      hypridle # idle daemon
      hyprland-qt-support # Qt integration fixes
      hyprland-qtutils # Hyprland Qt helpers
      hyprpicker # color picker
      hyprpolkitagent # polkit agent
      hyprprop # xprop-like tool for Hyprland
      hyprutils # core utils for Hyprland
      kdePackages.qt6ct # Qt6 config tool
      pyprland # Hyprland plugin system
      upower # power management daemon
    ]);
    programs.hyprlock.enable = true;
  }
