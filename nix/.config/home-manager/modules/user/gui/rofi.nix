{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.gui.enable {
    home.packages = with pkgs; [
      rofi-pass-wayland # pass interface for rofi-wayland
      (rofi-wayland.override {
        plugins = [
          rofi-file-browser # file browser plugin
          pkgs.neg.rofi_games # custom games launcher
        ];
      }) # modern dmenu alternative
    ];
  }
