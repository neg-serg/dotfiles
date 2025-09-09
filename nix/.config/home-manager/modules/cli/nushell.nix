{ lib, pkgs, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoNuConf = "${config.lib.neg.dotfilesRoot}/nix/.config/home-manager/modules/cli/nushell-conf";
in {
  # Ensure Nushell is available
  home.packages = [ pkgs.nushell ];

  # Remove stale ~/.config/nushell symlink from older generations before linking
  home.activation.fixNuConfigDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      NDIR="${config.xdg.configHome}/nushell"
      if [ -L "$NDIR" ]; then
        rm -f "$NDIR"
      fi
    '';

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."nushell" = {
    source = l repoNuConf;
    recursive = true;
  };
}
