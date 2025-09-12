{
  lib,
  config,
  pkgs,
  hy3,
  ...
}:
with lib; let
  hy3Plugin = hy3.packages.${pkgs.system}.hy3;
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in
  mkIf config.features.gui.enable (lib.mkMerge [
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        settings = {
          # Load permissions first, then the main init
          source = [
            "${config.xdg.configHome}/hypr/permissions.conf"
            "${config.xdg.configHome}/hypr/init.conf"
          ];
        };
        systemd.variables = ["--all"];
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
    # Live-editable Hyprland configuration (safe guards via helper)
    # Permissions + plugin load prelude (ensures correct order on first start)
    (xdg.mkXdgText "hypr/permissions.conf" ''
      ecosystem {
        enforce_permissions = 1
      }
      permission = ${hy3Plugin}/lib/libhy3.so, plugin, allow
      permission = ${pkgs.grim}/bin/grim, screencopy, allow
      permission = ${pkgs.hyprlock}/bin/hyprlock, screencopy, allow
      plugin = ${hy3Plugin}/lib/libhy3.so
    '')
    (xdg.mkXdgSource "hypr/init.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/init.conf" false))
    (xdg.mkXdgSource "hypr/rules.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/rules.conf" false))
    (xdg.mkXdgSource "hypr/bindings.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/bindings.conf" false))
    (xdg.mkXdgSource "hypr/autostart.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/autostart.conf" false))
    (xdg.mkXdgSource "hypr/workspaces.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/workspaces.conf" false))
    (xdg.mkXdgSource "hypr/pyprland.toml" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/pyprland.toml" false))
  ])
