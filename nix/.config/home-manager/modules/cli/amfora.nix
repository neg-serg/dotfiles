{
  pkgs,
  lib,
  config,
  ...
}:
let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
    # Install amfora and provide its config via XDG
    home.packages = config.lib.neg.pkgsList [pkgs.amfora];
  }
  (xdg.mkXdgSource "amfora" { source = ./amfora-conf; })
]
