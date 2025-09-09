{
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.user.services.openrgb =
    lib.recursiveUpdate {
      Unit.Description = "OpenRGB daemon with profile";
      Service = {
        ExecStart = "${pkgs.openrgb}/bin/openrgb --server -p neg.orp";
        RestartSec = "30";
        StartLimitBurst = "8";
      };
    } (config.lib.neg.systemdUser.mkUnitFromPresets {
      presets = ["defaultWanted" "dbusSocket"];
      partOf = ["graphical-session.target"]; # tie lifecycle to session
    });
}
