{
  lib,
  config,
  pkgs,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
    # Ensure Nushell is available
    home.packages = config.lib.neg.filterByExclude [pkgs.nushell];
  }
  # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "nushell" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/cli/nushell-conf" true))
]
