{ lib, config, xdg, ... }:
lib.mkIf (config.features.gui.enable or false) (lib.mkMerge [
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "kitty" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/kitty/conf";
    recursive = true;
  })
])
