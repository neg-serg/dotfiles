{ lib, pkgs, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoRmpcConf = "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/media/audio/rmpc/conf";
in {
  # Ensure rmpc is installed
  home.packages = [ pkgs.rmpc ];

  # Remove stale ~/.config/rmpc symlink from older generations, then link live
  home.activation.fixRmpcConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      RDIR="${config.xdg.configHome}/rmpc"
      if [ -L "$RDIR" ]; then
        rm -f "$RDIR"
      fi
    '';

  xdg.configFile."rmpc" = {
    source = l repoRmpcConf;
    recursive = true;
  };
}

