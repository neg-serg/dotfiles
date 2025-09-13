{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
  mkIf config.features.gui.enable (let xdg = import ../../lib/xdg-helpers.nix { inherit lib; }; in lib.mkMerge [
    {
      home.packages = config.lib.neg.pkgsList [pkgs.walker];
    }
    # Live-editable config via helper (guards parent dir and target)
    (xdg.mkXdgSource "walker" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/walker/conf" true))
  ])
