{
  lib,
  pkgs,
  config,
  bzmenuProvider ? null,
  ...
}:
with lib;
  mkIf config.features.gui.enable (
    let
      devSpeed = config.features.devSpeed.enable or false;
      groups = {
        core = [
          pkgs.cliphist # wayland clipboard history
          pkgs.espanso # system-wide text expander
          pkgs.matugen # theme generator (pywal-like)
        ];
        # extras evaluated only when enabled (prevents pulling input in dev-speed)
        extras = lib.optionals (! devSpeed && (bzmenuProvider != null)) [ (bzmenuProvider pkgs) ];
      };
      flags = {
        core = true;
        extras = true;
      };
    in {
      programs.wallust.enable = true;
      home.packages = config.lib.neg.pkgsList (config.lib.neg.mkEnabledList flags groups);
    }
  )
