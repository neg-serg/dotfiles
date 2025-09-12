{
  lib,
  config,
  pkgs,
  ...
}: let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
    # Ensure rmpc is installed
    home.packages = config.lib.neg.filterByExclude [pkgs.rmpc];
  }
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "rmpc" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/media/audio/rmpc/conf" true))
]
