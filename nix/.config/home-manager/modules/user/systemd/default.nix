{pkgs, ...}: {
  systemd.user.startServices = true;

  systemd.user.services = {
    # RGB lights daemon
    openrgb = {
      Unit = {
        Description = "OpenRGB daemon with profile";
        After = [
          "dbus.socket" # requires D-Bus activation
        ];
        PartOf = [
          "graphical-session.target" # tie lifecycle to graphical session
        ];
      };
      Service = {
        ExecStart = "${pkgs.openrgb}/bin/openrgb --server -p neg.orp";
        RestartSec = "30";
        StartLimitBurst = "8";
      };
      Install = {
        WantedBy = [
          "default.target" # start by default in user session
        ];
      };
    };

    # Optimize screenshots automatically
    shot-optimizer = {
      Unit = {
        Description = "Optimize screenshots";
        After = [
          "sockets.target" # ensure sockets established first
        ];
      };
      Service = {
        ExecStart = "%h/bin/shot-optimizer";
        WorkingDirectory = "%h/pic/shots";
        PassEnvironment = "HOME";
        Restart = "on-failure";
        RestartSec = "1";
        StartLimitBurst = "0";
      };
      Install = {
        WantedBy = [
          "default.target" # start by default in user session
        ];
      };
    };

    # Notify about picture directories
    pic-dirs = {
      Unit = {
        Description = "Pic dirs notification";
        After = [
          "sockets.target" # ensure sockets established first
        ];
        StartLimitIntervalSec = "0";
      };
      Service = {
        ExecStart = "/bin/sh -lc '%h/bin/pic-dirs-list'";
        PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
        Restart = "on-failure";
        RestartSec = "1";
      };
      Install = {
        WantedBy = [
          "default.target" # start by default in user session
        ];
      };
    };

    # Pyprland daemon
    pyprland = {
      Unit = {
        Description = "Pyprland daemon for Hyprland";
        After = [
          "graphical-session.target" # needs running session
        ];
        Wants = [
          "graphical-session.target" # pull in the session target
        ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.pyprland}/bin/pypr";
        Restart = "on-failure";
        RestartSec = "1";
        Slice = "background-graphical.slice";
      };
      Install = {
        WantedBy = [
          "graphical-session.target" # start with graphical session
        ];
      };
    };

    # Quickshell session
    quickshell = {
      Unit = {
        Description = "Quickshell Wayland shell";
        After = [
          "graphical-session.target" # ensure compositor/session up
        ];
        Wants = [
          "graphical-session.target" # pull in session
        ];
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
      Install = {
        WantedBy = [
          "graphical-session.target" # start with graphical session
        ];
      };
    };
  };
}
