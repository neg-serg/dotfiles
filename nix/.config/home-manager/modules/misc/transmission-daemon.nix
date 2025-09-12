{
  lib,
  config,
  ...
}: {
  # Keep existing config directory as-is; only remove if symlink is broken.
  # This avoids nuking a valid symlinked external config (preserves history/resume).
  home.activation.fixTransmissionDaemonDir =
    lib.hm.dag.entryBefore ["linkGeneration"] ''
      set -eu
      p="${config.xdg.configHome}/transmission-daemon"
      if [ -L "$p" ] && [ ! -e "$p" ]; then
        rm -f "$p"
      fi
    '';

  # Link selected config files from repo; runtime subdirs (resume,torrents) remain local
  xdg.configFile."transmission-daemon/settings.json" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/misc/transmission-daemon/conf/settings.json" false;
  xdg.configFile."transmission-daemon/bandwidth-groups.json" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/misc/transmission-daemon/conf/bandwidth-groups.json" false;
}
