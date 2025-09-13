{
  lib,
  config,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  # dircolors, f-sy-h, zsh from dotfiles; inputrc inline
  (xdg.mkXdgSource "dircolors" (config.lib.neg.mkDotfilesSymlink "shell/.config/dircolors" true))
  (xdg.mkXdgSource "f-sy-h" (config.lib.neg.mkDotfilesSymlink "shell/.config/f-sy-h" true))
  (xdg.mkXdgText "inputrc" (builtins.readFile ./inputrc))
  (xdg.mkXdgSource "zsh" (config.lib.neg.mkDotfilesSymlink "shell/.config/zsh" true))
]

