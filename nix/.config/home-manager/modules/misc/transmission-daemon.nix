{ lib, config, ... }:
{
  # Ensure ~/.config/transmission-daemon is a real directory (not a stale HM symlink)
  home.activation.fixTransmissionDaemonDir =
    config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/transmission-daemon";

  # Link selected config files from repo; runtime subdirs (resume,torrents) remain local
  xdg.configFile."transmission-daemon/settings.json" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/misc/transmission-daemon/conf/settings.json" false;
  xdg.configFile."transmission-daemon/bandwidth-groups.json" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/misc/transmission-daemon/conf/bandwidth-groups.json" false;
}
