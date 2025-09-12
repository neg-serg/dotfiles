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
    # Install dosbox-staging and ship config via XDG
    home.packages = config.lib.neg.filterByExclude [pkgs.dosbox-staging];
  }
  (xdg.mkXdgSource "dosbox" { source = ./dosbox-conf; })
]
