{ pkgs, config, ... }:
{
  # Install amfora and provide its config via XDG
  home.packages = config.lib.neg.filterByExclude [ pkgs.amfora ];

  xdg.configFile."amfora".source = ./amfora-conf;
}
