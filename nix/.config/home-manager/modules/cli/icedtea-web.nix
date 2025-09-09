{ lib, pkgs, ... }:
{
  # Install icedtea-web if available and ship its config via XDG
  home.packages = lib.optional (pkgs ? icedtea-web) pkgs.icedtea-web;

  xdg.configFile."icedtea-web".source = ./icedtea-web-conf;
}

