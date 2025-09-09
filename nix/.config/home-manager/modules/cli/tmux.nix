{ pkgs, ... }:
{
  # Install tmux and provide its configuration via XDG
  home.packages = [ pkgs.tmux pkgs.xsel pkgs.python3 ];

  # Ship the entire tmux config directory (conf + bin)
  xdg.configFile."tmux".source = ./tmux-conf;
}

