{
  lib,
  config,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  # Live-editable out-of-store symlink via helper (guards parent dir and target)
  (xdg.mkXdgSource "rustmission" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/misc/rustmission/conf" true))
]
