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
  # Fallback: if repo init.conf is absent for any reason, generate a minimal one
  repoInit = ./conf/init.conf;
  hasRepoInit = builtins.pathExists repoInit;
in
  mkIf config.features.gui.enable (lib.mkMerge [
    {
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
    (lib.mkIf hasRepoInit (xdg.mkXdgSource "hypr/init.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/init.conf" false)))
    (lib.mkIf (!hasRepoInit) (xdg.mkXdgText "hypr/init.conf" ''
      # Minimal Hyprland init (auto-generated fallback)
      source = ~/.config/hypr/autostart.conf
      source = ~/.config/hypr/rules.conf
      source = ~/.config/hypr/bindings.conf
      source = ~/.config/hypr/workspaces.conf
    ''))
    (xdg.mkXdgSource "hypr/rules.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/rules.conf" false))
    (xdg.mkXdgSource "hypr/bindings.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/bindings.conf" false))
    (xdg.mkXdgSource "hypr/autostart.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/autostart.conf" false))
    (xdg.mkXdgSource "hypr/workspaces.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/workspaces.conf" false))
    (xdg.mkXdgSource "hypr/pyprland.toml" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/pyprland.toml" false))
  ])
