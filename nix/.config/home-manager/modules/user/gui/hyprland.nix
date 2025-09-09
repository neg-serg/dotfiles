{
  lib,
  config,
  pkgs,
  hy3,
  ...
}:
with lib; let
  hy3Plugin = hy3.packages.${pkgs.system}.hy3;
  l = config.lib.file.mkOutOfStoreSymlink;
  repoHyprConf = "${config.lib.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/hypr/conf";
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
    xdg.configFile = {
      "hypr/init.conf" = {
        source = l "${repoHyprConf}/init.conf";
        recursive = false;
        force = true;
        # onChange = "${pkgs.hyprland}/bin/hyprctl reload || true"; # optional
      };
      "hypr/rules.conf" = {
        source = l "${repoHyprConf}/rules.conf";
        recursive = false;
        force = true;
      };
      "hypr/bindings.conf" = {
        source = l "${repoHyprConf}/bindings.conf";
        recursive = false;
        force = true;
      };
      "hypr/autostart.conf" = {
        source = l "${repoHyprConf}/autostart.conf";
        recursive = false;
        force = true;
      };
      "hypr/workspaces.conf" = {
        source = l "${repoHyprConf}/workspaces.conf";
        recursive = false;
        force = true;
      };
      "hypr/pyprland.toml" = {
        source = l "${repoHyprConf}/pyprland.toml";
        recursive = false;
        force = true;
      };
    };
    home.packages = with pkgs; [
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
    ];
    programs.hyprlock.enable = true;
  }
