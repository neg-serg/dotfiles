{
  pkgs,
  config,
  ...
}: {
  # Install dosbox-staging and ship config via XDG
  home.packages = config.lib.neg.filterByExclude [pkgs.dosbox-staging];

  xdg.configFile."dosbox".source = ./dosbox-conf;
}
