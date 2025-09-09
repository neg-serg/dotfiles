{ pkgs, ... }:
{
  home.packages = [ pkgs.fuzzel ];
  xdg.configFile."fuzzel".source = ./fuzzel-conf;
}

