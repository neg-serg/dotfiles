{ pkgs, lib, config, ... }:
with lib;
mkIf (config.features.media.audio.apps.enable or false) {
  systemd.user.services.playerctld = lib.mkMerge [
    {
      Unit = { Description = "Keep track of media player activity"; };
      Service = {
        Type = "oneshot";
        ExecStart = "${lib.getExe' pkgs.playerctl "playerctld"} daemon";
      };
    }
    (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; })
  ];
}
