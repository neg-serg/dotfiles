{
  lib,
  config,
  ...
}:
with lib;
  mkIf config.features.web.enable (let xdg = import ../../lib/xdg-helpers.nix { inherit lib; }; in lib.mkMerge [
    # Live-editable config via helper (guards parent dir and target)
    (xdg.mkXdgSource "tridactyl" (config.lib.neg.mkDotfilesSymlink "misc/.config/tridactyl" true))
  ])
