{
  pkgs,
  lib,
  config,
  ...
}:
with {
  transmission = pkgs.transmission_4;
}; {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    bitmagnet # dht crawler
    pkgs.neg.bt_migrate # torrent migrator
    rustmission # new transmission client
  ]);

  systemd.user.services.transmission-daemon = lib.recursiveUpdate {
    Unit = {
      Description = "transmission service";
      ConditionPathExists = "${transmission}/bin/transmission-daemon";
    };
    Service = {
      Type = "notify";
      ExecStart = "${transmission}/bin/transmission-daemon -g %E/transmission-daemon -f --log-error";
      Restart = "on-failure";
      RestartSec = "30";
      StartLimitBurst = "8";
      ExecReload = "${pkgs.util-linux}/bin/kill -s HUP $MAINPID";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["net" "defaultWanted"];});
}
