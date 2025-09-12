{
  lib,
  config,
  ...
}: let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "kitty" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/kitty/conf" true))
]
