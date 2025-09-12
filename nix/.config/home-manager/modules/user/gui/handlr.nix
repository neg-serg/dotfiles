{ pkgs, config, ... }:
{
  home.packages = config.lib.neg.filterByExclude [ pkgs.handlr ];
  xdg.configFile."handlr".source = ./handlr-conf;
}
