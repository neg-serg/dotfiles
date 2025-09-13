{
  pkgs,
  lib,
  config,
  ...
}:
let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  # Install tmux and provide its configuration via XDG
  # Avoid adding base python when a python env is present elsewhere (prevents bin/idle conflict)
  {
    home.packages = config.lib.neg.pkgsList [pkgs.tmux pkgs.wl-clipboard];

  }
  # Ship the entire tmux config directory (conf + bin) via pure helper
  (xdg.mkXdgSource "tmux" { source = ./tmux-conf; })
]
