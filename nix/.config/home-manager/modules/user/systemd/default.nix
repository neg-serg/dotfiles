{
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.user.startServices = true;

  systemd.user.services = {
    # RGB lights daemon
    openrgb =
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

    # Optimize screenshots automatically
    shot-optimizer = lib.recursiveUpdate {
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

    # Notify about picture directories
    pic-dirs = lib.recursiveUpdate {
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
    } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["defaultWanted" "socketsTarget"];});

    # Pyprland daemon
    pyprland = lib.recursiveUpdate {
      Unit.Description = "Pyprland daemon for Hyprland";
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.pyprland}/bin/pypr";
        Restart = "on-failure";
        RestartSec = "1";
        Slice = "background-graphical.slice";
      };
    } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];});

    # Quickshell session
    quickshell = lib.recursiveUpdate {
      Unit.Description = "Quickshell Wayland shell";
      Service = {
        ExecStart = "${pkgs.quickshell}/bin/qs";
        # Reduce noisy MPRIS Position warnings while keeping other logs
        # The target name matches the warning source: quickshell.dbus.properties
        Environment = ["RUST_LOG=info,quickshell.dbus.properties=error"];
        Restart = "on-failure";
        RestartSec = "1";
        Slice = "background-graphical.slice";
        # Uncomment if you need explicit env passing:
        # PassEnvironment = [ "WAYLAND_DISPLAY" "XDG_RUNTIME_DIR" ];
      };
    } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["graphical"];});
  };
}
