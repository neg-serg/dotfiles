{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    evhz # show mouse refresh rate
    openrgb # manage rgb highlight
  ]);
}
