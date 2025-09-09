{ pkgs, ... }:
{
  home.packages = [ pkgs.handlr ];
  xdg.configFile."handlr".source = ./handlr-conf;
}

