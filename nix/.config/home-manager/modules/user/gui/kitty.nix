{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoKittyConf = "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/user/gui/kitty/conf";
in {
  # Remove stale ~/.config/kitty symlink from older generations before linking
  home.activation.fixKittyConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      KDIR="${config.xdg.configHome}/kitty"
      if [ -L "$KDIR" ]; then
        rm -f "$KDIR"
      fi
    '';

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."kitty" = {
    source = l repoKittyConf;
    recursive = true;
  };
}

