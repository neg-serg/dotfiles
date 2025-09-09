{pkgs, ...}: {
  systemd.user.startServices = true;

  systemd.user.services = {
    # RGB lights daemon
    openrgb = {
      Unit = {
        Description = "OpenRGB daemon with profile";
        After = ["dbus.socket"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.openrgb}/bin/openrgb --server -p neg.orp";
        RestartSec = "30";
        StartLimitBurst = "8";
      };
      Install = {WantedBy = ["default.target"];};
    };

    # Optimize screenshots automatically
    shot-optimizer = {
      Unit = {
        Description = "Optimize screenshots";
        After = ["sockets.target"];
      };
      Service = {
        ExecStart = "%h/bin/shot-optimizer";
        WorkingDirectory = "%h/pic/shots";
        PassEnvironment = "HOME";
        Restart = "on-failure";
        RestartSec = "1";
        StartLimitBurst = "0";
      };
      Install = {WantedBy = ["default.target"];};
    };

    # Notify about picture directories
    pic-dirs = {
      Unit = {
        Description = "Pic dirs notification";
        After = ["sockets.target"];
        StartLimitIntervalSec = "0";
      };
      Service = {
        ExecStart = "/bin/sh -lc '%h/bin/pic-dirs-list'";
        PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
        Restart = "on-failure";
        RestartSec = "1";
      };
      Install = {WantedBy = ["default.target"];};
    };

    # Pyprland daemon
    pyprland = {
      Unit = {
        Description = "Pyprland daemon for Hyprland";
        After = ["graphical-session.target"];
        Wants = ["graphical-session.target"];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.pyprland}/bin/pypr";
        Restart = "on-failure";
        RestartSec = "1";
        Slice = "background-graphical.slice";
      };
      Install = {WantedBy = ["graphical-session.target"];};
    };

    # Quickshell session
    quickshell = {
      Unit = {
        Description = "Quickshell Wayland shell";
        After = ["graphical-session.target"];
        Wants = ["graphical-session.target"];
      };
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
      Install = {WantedBy = ["graphical-session.target"];};
    };
  };
}
