{
  lib,
  pkgs,
  config,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkIf config.features.cli.icedteaWeb.enable (
  lib.mkMerge [
    # Install icedtea-web if available and ship its config via XDG
    {
      home.packages =
        config.lib.neg.filterByExclude (
          lib.optional (pkgs ? icedtea-web) pkgs.icedtea-web
        );
    }
    (xdg.mkXdgSource "icedtea-web" { source = ./icedtea-web-conf; })
  ]
)
