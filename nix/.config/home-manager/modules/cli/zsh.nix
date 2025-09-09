{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoZshConf = "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/cli/zsh-conf";
in {
  # Remove stale ~/.config/zsh symlink from older generations before linking
  home.activation.fixZshConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      ZDIR="${config.xdg.configHome}/zsh"
      if [ -L "$ZDIR" ]; then
        rm -f "$ZDIR"
      fi
    '';

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."zsh" = {
    source = l repoZshConf;
    recursive = true;
  };
}

