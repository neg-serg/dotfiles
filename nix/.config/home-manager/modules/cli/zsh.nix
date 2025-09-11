{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  # Use existing zsh config stored in repo under shell/.config/zsh
  repoZshConf = "${config.lib.neg.dotfilesRoot}/shell/.config/zsh";
in {
  # Remove stale ~/.config/zsh symlink from older generations before linking
  home.activation.fixZshConfigDir = config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/zsh";

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."zsh" = {
    source = l repoZshConf;
    recursive = true;
  };
}
