{
  lib,
  config,
  ...
}: {
  systemd.user.services."pic-dirs" = lib.recursiveUpdate {
    Unit = {
      Description = "Pic dirs notification";
      StartLimitIntervalSec = "0";
    };
    Service = {
      ExecStart = "/bin/sh -lc '%h/bin/pic-dirs-list'";
      PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
      Restart = "on-failure";
      RestartSec = "1";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["defaultWanted"];});
}
