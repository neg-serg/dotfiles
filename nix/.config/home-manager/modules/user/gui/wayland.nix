{
  lib,
  pkgs,
  config,
  iwmenuProvider ? null,
  ...
}:
with lib;
  mkIf config.features.gui.enable (
    let
      devSpeed = config.features.devSpeed.enable or false;
      groups = {
        core = [
          pkgs.dragon-drop # drag-n-drop from console
          pkgs.gowall # tool to convert a Wallpaper's color scheme / palette
          pkgs.grimblast # hyprland screenshot tool
          pkgs.grim # to take screenshots
          pkgs.slurp # select region in wayland compositor
          pkgs.swww # wallpaper daemon for wayland
          pkgs.waybar # status bar (Wayland)
          pkgs.waypipe # proxy for wayland similar to ssh -X
          pkgs.wev # xev for wayland
          pkgs.wf-recorder # tool to make screencasts
          pkgs.wl-clipboard # copy-paste for wayland
          pkgs.wl-clip-persist # clipboard persistence tool
          pkgs.wtype # typing for wayland
        ];
        # extras evaluated only when enabled (prevents pulling input in dev-speed)
        extras = lib.optionals (! devSpeed && (iwmenuProvider != null)) [ (iwmenuProvider pkgs) ];
      };
      flags = { core = true; extras = true; };
    in {
      home.sessionVariables = {};
      home.packages = config.lib.neg.pkgsList (config.lib.neg.mkEnabledList flags groups);
    }
  )
