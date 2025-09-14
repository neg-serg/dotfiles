{
  pkgs,
  lib,
  config,
  ...
}:
with {
  transmission = pkgs.transmission_4;
}; {
  # Ensure runtime subdirectories exist even if the config dir is a symlink
  # to an external location. This avoids "resume: No such file or directory"
  # on first start after activation.
  home.activation.ensureTransmissionDirs =
    config.lib.neg.mkEnsureDirsAfterWrite [
      "${config.xdg.configHome}/transmission-daemon/resume"
      "${config.xdg.configHome}/transmission-daemon/torrents"
      "${config.xdg.configHome}/transmission-daemon/blocklists"
    ];
  home.packages = with pkgs; config.lib.neg.pkgsList [
    bitmagnet # dht crawler
    pkgs.neg.bt_migrate # torrent migrator
    rustmission # new transmission client
  ];

  systemd.user.services.transmission-daemon = lib.recursiveUpdate {
    Unit = {
      Description = "transmission service";
      ConditionPathExists = "${transmission}/bin/transmission-daemon";
    };
    Service = {
      Type = "notify";
      ExecStart = "${transmission}/bin/transmission-daemon -g ${config.xdg.configHome}/transmission-daemon -f --log-error";
      Restart = "on-failure";
      RestartSec = "30";
      StartLimitBurst = "8";
      ExecReload = "${pkgs.util-linux}/bin/kill -s HUP $MAINPID";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["net" "defaultWanted"];});
}
