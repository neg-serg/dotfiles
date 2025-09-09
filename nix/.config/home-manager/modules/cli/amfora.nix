{ pkgs, ... }:
{
  # Install amfora and provide its config via XDG
  home.packages = [ pkgs.amfora ];

  xdg.configFile."amfora".source = ./amfora-conf;
}

