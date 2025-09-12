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

  # Remove stale ~/.config/icedtea-web symlink before linking
  home.activation.fixIcedteaConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/icedtea-web";

  xdg.configFile."icedtea-web".source = ./icedtea-web-conf;
}
