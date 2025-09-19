{ pkgs, lib, config, xdg, ... }:
lib.mkIf (config.features.gui.enable or false) (lib.mkMerge [
  {
    home.packages = config.lib.neg.pkgsList [pkgs.handlr];
  }
  (xdg.mkXdgConfigToml "handlr/handlr.toml" {
    enable_selector = false;
    selector = "rofi -dmenu -p 'Open With: '";
  })
])
