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
    home.packages = config.lib.neg.pkgsList [pkgs.handlr];
  }
  (xdg.mkXdgSource "handlr" { source = ./handlr-conf; })
]
