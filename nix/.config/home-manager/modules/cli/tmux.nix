{ pkgs, ... }:
{
  # Install tmux and provide its configuration via XDG
  # Avoid adding base python when a python env is present elsewhere (prevents bin/idle conflict)
  home.packages = [ pkgs.tmux pkgs.xsel ];

  # Ship the entire tmux config directory (conf + bin)
  xdg.configFile."tmux".source = ./tmux-conf;
}
