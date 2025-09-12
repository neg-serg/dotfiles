{
  lib,
  config,
  ...
}: let
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  {
    programs = {
      home-manager.enable = true; # Let Home Manager install and manage itself.
    };
  }
  # Make the repo available at ~/.config/home-manager via helper
  (xdg.mkXdgSource "home-manager" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager" true))
]
