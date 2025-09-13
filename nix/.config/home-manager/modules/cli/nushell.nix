{
  lib,
  config,
  pkgs,
  inputs,
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
  # Provide nupm modules via flake input instead of vendoring sources
  (xdg.mkXdgSource "nushell/modules/nupm" { source = "${inputs.nupm}/modules/nupm"; recursive = true; })
]
