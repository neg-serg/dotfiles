{ pkgs, lib, config, ... }:
with lib; {
  systemd.user.startServices = true;

  # Quickshell session
  systemd.user.services.quickshell = lib.recursiveUpdate {
    Unit.Description = "Quickshell Wayland shell";
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs";
      Environment = ["RUST_LOG=info,quickshell.dbus.properties=error"];
      Restart = "on-failure";
      RestartSec = "1";
      Slice = "background-graphical.slice";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; });

  # Pyprland daemon
  systemd.user.services.pyprland = lib.recursiveUpdate {
    Unit.Description = "Pyprland daemon for Hyprland";
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.pyprland}/bin/pypr";
      Restart = "on-failure";
      RestartSec = "1";
      Slice = "background-graphical.slice";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; });

  # Pic dirs notifier
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
  } (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; });

  # OpenRGB daemon
  systemd.user.services.openrgb = lib.recursiveUpdate {
    Unit.Description = "OpenRGB daemon with profile";
    Service = {
      ExecStart = "${pkgs.openrgb}/bin/openrgb --server -p neg.orp";
      RestartSec = "30";
      StartLimitBurst = "8";
    };
  } (config.lib.neg.systemdUser.mkUnitFromPresets {
    presets = ["defaultWanted" "dbusSocket"];
    partOf = ["graphical-session.target"];
  });
}
