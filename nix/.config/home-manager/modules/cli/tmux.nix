{
  pkgs,
  config,
  ...
}: {
  # Install tmux and provide its configuration via XDG
  # Avoid adding base python when a python env is present elsewhere (prevents bin/idle conflict)
  home.packages = config.lib.neg.filterByExclude [pkgs.tmux pkgs.wl-clipboard];

  # Ship the entire tmux config directory (conf + bin)
  xdg.configFile."tmux".source = ./tmux-conf;
}
