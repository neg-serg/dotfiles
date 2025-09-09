{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoTxConf = "${config.home.homeDirectory}/.dotfiles/nix/.config/home-manager/modules/misc/transmission-daemon/conf";
in {
  # Ensure ~/.config/transmission-daemon is a real directory (not a stale HM symlink)
  home.activation.fixTransmissionDaemonDir =
    lib.hm.dag.entryBefore [ "linkGeneration" ] ''
      set -eu
      TDIR="${config.xdg.configHome}/transmission-daemon"
      if [ -L "$TDIR" ]; then
        rm -f "$TDIR"
      fi
      mkdir -p "$TDIR"
    '';

  # Link selected config files from repo; runtime subdirs (resume,torrents) remain local
  xdg.configFile."transmission-daemon/settings.json".source = l "${repoTxConf}/settings.json";
  xdg.configFile."transmission-daemon/bandwidth-groups.json".source =
    l "${repoTxConf}/bandwidth-groups.json";
}
