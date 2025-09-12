{
  pkgs,
  lib,
  config,
  ...
}:
let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
    home.packages = config.lib.neg.filterByExclude [pkgs.fuzzel];
  }
  (xdg.mkXdgSource "fuzzel" { source = ./fuzzel-conf; })
]
