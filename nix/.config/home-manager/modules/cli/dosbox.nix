{ pkgs, lib, config, xdg, ... }:
lib.mkMerge [
  {
    # Install dosbox-staging and ship config via XDG
    home.packages = config.lib.neg.pkgsList [pkgs.dosbox-staging];
  }
  (xdg.mkXdgSource "dosbox" { source = ./dosbox-conf; })
]
