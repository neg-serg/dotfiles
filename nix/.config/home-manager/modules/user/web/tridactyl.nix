{ lib, config, ... }:
with lib; let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoTridactylConf = "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/user/web/tridactyl/conf";
in mkIf config.features.web.enable {
  # Remove stale ~/.config/tridactyl symlink from older generations before linking
  home.activation.fixTridactylConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      TDIR="${config.xdg.configHome}/tridactyl"
      if [ -L "$TDIR" ]; then
        rm -f "$TDIR"
      fi
    '';

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."tridactyl" = {
    source = l repoTridactylConf;
    recursive = true;
  };
}

