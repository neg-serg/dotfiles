{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
  mkIf config.features.gui.enable {
    programs.wallust.enable = true;
    home.packages = with pkgs; config.lib.neg.pkgsList [
      cliphist # wayland clipboard history
      espanso # system-wide text expander
      inputs.bzmenu.packages.${pkgs.system}.default # Bluetooth menu
      matugen # theme generator (pywal-like)
    ];
  }
