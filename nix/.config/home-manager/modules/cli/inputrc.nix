{ lib, config, ... }:
let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  (xdg.mkXdgText "inputrc" (builtins.readFile ./inputrc))
]
