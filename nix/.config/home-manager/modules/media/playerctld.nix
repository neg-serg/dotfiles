{
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.user.services.playerctld = lib.recursiveUpdate {
    Unit.Description = "Keep track of media player activity";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.playerctl}/bin/playerctld daemon";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["defaultWanted"];});
}
