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
      home.packages = with pkgs;
        config.lib.neg.pkgsList (
          let
            groups = { iced = lib.optionals (pkgs ? icedtea-web) [ icedtea-web ]; };
            flags = { iced = (pkgs ? icedtea-web); };
          in config.lib.neg.mkEnabledList flags groups
        );
    }
    (xdg.mkXdgSource "icedtea-web" { source = ./icedtea-web-conf; })
  ]
)
