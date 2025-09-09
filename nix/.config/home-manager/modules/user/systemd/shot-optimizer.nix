{
  lib,
  config,
  ...
}: {
  systemd.user.services."shot-optimizer" = lib.recursiveUpdate {
    Unit.Description = "Optimize screenshots";
    Service = {
      ExecStart = "%h/bin/shot-optimizer";
      WorkingDirectory = "%h/pic/shots";
      PassEnvironment = "HOME";
      Restart = "on-failure";
      RestartSec = "1";
      StartLimitBurst = "0";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["defaultWanted" "socketsTarget"];});
}
