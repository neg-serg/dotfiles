{
  lib,
  config,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  # Live-editable config via pure helper (guards parent dir and target)
  (xdg.mkXdgSource "f-sy-h" (config.lib.neg.mkDotfilesSymlink "shell/.config/f-sy-h" true))
]
