{ pkgs, ... }:
{
  # Install dosbox-staging and ship config via XDG
  home.packages = [ pkgs.dosbox-staging ];

  xdg.configFile."dosbox".source = ./dosbox-conf;
}

