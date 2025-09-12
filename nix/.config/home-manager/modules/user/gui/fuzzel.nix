{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.filterByExclude [pkgs.fuzzel];
  xdg.configFile."fuzzel".source = ./fuzzel-conf;
}
