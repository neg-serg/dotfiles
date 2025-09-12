{
  lib,
  pkgs,
  config,
  ...
}: {
  # Install icedtea-web if available and ship its config via XDG
  home.packages =
    config.lib.neg.filterByExclude (
      lib.optional (pkgs ? icedtea-web) pkgs.icedtea-web
    );

  xdg.configFile."icedtea-web".source = ./icedtea-web-conf;
}
