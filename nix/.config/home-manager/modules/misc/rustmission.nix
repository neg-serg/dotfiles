{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoRustmissionConf = "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/misc/rustmission/conf";
in {
  # Remove stale ~/.config/rustmission symlink before linking
  home.activation.fixRustmissionConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      RDIR="${config.xdg.configHome}/rustmission"
      if [ -L "$RDIR" ]; then
        rm -f "$RDIR"
      fi
    '';

  # Live-editable out-of-store symlink to repo copy
  xdg.configFile."rustmission" = {
    source = l repoRustmissionConf;
    recursive = true;
  };
}

