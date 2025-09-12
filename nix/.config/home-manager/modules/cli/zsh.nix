{
  lib,
  config,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  # Live-editable config via pure helper (guards parent dir and target)
  (xdg.mkXdgSource "zsh" (config.lib.neg.mkDotfilesSymlink "shell/.config/zsh" true))
]
