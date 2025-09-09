{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoDircolorsConf = "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/cli/dircolors-conf";
in {
  # Remove stale ~/.config/dircolors symlink from older generations before linking
  home.activation.fixDircolorsConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      DDIR="${config.xdg.configHome}/dircolors"
      if [ -L "$DDIR" ]; then
        rm -f "$DDIR"
      fi
    '';

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."dircolors" = {
    source = l repoDircolorsConf;
    recursive = true;
  };
}

