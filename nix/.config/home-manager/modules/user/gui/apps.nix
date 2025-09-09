{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
  mkIf config.features.gui {
    programs.wallust.enable = true;
    home.packages = with pkgs; [
      cliphist # wayland clipboard history
      espanso # system-wide text expander
      inputs.bzmenu.packages.${pkgs.system}.default # Bluetooth menu
      matugen # theme generator (pywal-like)
    ];
  }
