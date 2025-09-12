{
  lib,
  config,
  ...
}: let
  xdg = import ../lib/xdg-helpers.nix { inherit lib; };
in lib.mkMerge [
  # Ensure zsh state dir exists for history and other files
  {
    home.activation.ensureZshStateDir =
      config.lib.neg.mkEnsureDirsAfterWrite [
        "${config.xdg.stateHome or "$HOME/.local/state"}/zsh"
      ];
  }
  # Live-editable config via pure helper (guards parent dir and target)
  (xdg.mkXdgSource "zsh" (config.lib.neg.mkDotfilesSymlink "shell/.config/zsh" true))
]
