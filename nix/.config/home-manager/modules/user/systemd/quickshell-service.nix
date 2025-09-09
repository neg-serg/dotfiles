{
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.user.services.quickshell = lib.recursiveUpdate {
    Unit.Description = "Quickshell Wayland shell";
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs";
      # Reduce noisy MPRIS Position warnings while keeping other logs
      # The target name matches the warning source: quickshell.dbus.properties
      Environment = ["RUST_LOG=info,quickshell.dbus.properties=error"];
      Restart = "on-failure";
      RestartSec = "1";
      Slice = "background-graphical.slice";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];});
}
