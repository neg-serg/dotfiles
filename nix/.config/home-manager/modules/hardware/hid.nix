{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.evhz # show mouse refresh rate
    pkgs.openrgb # manage rgb highlight
  ];
}
