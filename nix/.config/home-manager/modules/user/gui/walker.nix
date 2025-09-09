{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.gui.enable {
    home.packages = [
      pkgs.walker # application launcher (Wayland/X11)
    ];
  }
