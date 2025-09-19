{ pkgs, lib, config, ... }:
with lib;
lib.mkMerge [
  {
    systemd.user.startServices = true;
  }
  (lib.mkIf (config.features.gui.enable or false)
    (let
      picDirsRunner = pkgs.writeShellApplication {
        name = "pic-dirs-runner";
        text = ''
          set -euo pipefail
          exec "$HOME/bin/pic-dirs-list"
        '';
      };
    in {
      # Quickshell session (Qt-bound, skip in dev-speed)
      systemd.user.services =
        (lib.mkIf ((config.features.gui.qt.enable or false) && (! (config.features.devSpeed.enable or false))) {
          quickshell =
            lib.recursiveUpdate
              {
                Unit.Description = "Quickshell Wayland shell";
                Service = {
                  ExecStart = "${lib.getExe' pkgs.quickshell "qs"}";
                  Environment = ["RUST_LOG=info,quickshell.dbus.properties=error"];
                  Restart = "on-failure";
                  RestartSec = "1";
                  Slice = "background-graphical.slice";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; });
        })
        // {
          # Pyprland daemon (Hyprland helper)
          pyprland =
            lib.recursiveUpdate
              {
                Unit.Description = "Pyprland daemon for Hyprland";
                Service = {
                  Type = "simple";
                  ExecStart = "${lib.getExe' pkgs.pyprland "pypr"}";
                  Restart = "on-failure";
                  RestartSec = "1";
                  Slice = "background-graphical.slice";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["graphical"]; });

          # Pic dirs notifier
          "pic-dirs" =
            lib.recursiveUpdate
              {
                Unit = { Description = "Pic dirs notification"; StartLimitIntervalSec = "0"; };
                Service = {
                  ExecStart = "${picDirsRunner}/bin/pic-dirs-runner";
                  PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
                  Restart = "on-failure";
                  RestartSec = "1";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["defaultWanted"]; });

          # OpenRGB daemon
          openrgb =
            lib.recursiveUpdate
              {
                Unit = {
                  Description = "OpenRGB daemon with profile";
                  PartOf = ["graphical-session.target"];
                };
                Service = {
                  ExecStart = "${lib.getExe pkgs.openrgb} --server -p neg.orp";
                  RestartSec = "30";
                  StartLimitBurst = "8";
                };
              }
              (config.lib.neg.systemdUser.mkUnitFromPresets {
                presets = ["dbusSocket" "defaultWanted"];
              });
        };
    }))
]
