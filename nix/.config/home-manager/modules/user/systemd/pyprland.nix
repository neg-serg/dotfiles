{
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.user.services.pyprland = lib.recursiveUpdate {
    Unit.Description = "Pyprland daemon for Hyprland";
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.pyprland}/bin/pypr";
      Restart = "on-failure";
      RestartSec = "1";
      Slice = "background-graphical.slice";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];});
}
