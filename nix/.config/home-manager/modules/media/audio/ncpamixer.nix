{ lib, ... }:
let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  (xdg.mkXdgText "ncpamixer.conf" (builtins.readFile ./ncpamixer.conf))
]
