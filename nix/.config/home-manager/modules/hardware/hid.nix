{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    evhz # show mouse refresh rate
    openrgb # manage rgb highlight
  ];
}
