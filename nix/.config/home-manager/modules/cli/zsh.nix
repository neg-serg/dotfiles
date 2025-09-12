{
  lib,
  config,
  ...
}: {
  # Remove stale ~/.config/zsh symlink from older generations before linking
  home.activation.fixZshConfigDir = config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/zsh";

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."zsh" = config.lib.neg.mkDotfilesSymlink "shell/.config/zsh" true;
}
