{ lib, pkgs, config, ... }:
with lib;
  mkIf (config.features.mail.enable && config.features.mail.vdirsyncer.enable) (let xdg = import ../../../lib/xdg-helpers.nix { inherit lib; }; in lib.mkMerge [
    {
      home.packages = config.lib.neg.pkgsList [
        pkgs.vdirsyncer # add vdirsyncer binary for sync and initialization
      ];

      # Ensure local storage directories exist
      home.activation.vdirsyncerDirs = config.lib.neg.mkEnsureDirsAfterWrite [
        "$HOME/.config/vdirsyncer/calendars"
        "$HOME/.config/vdirsyncer/contacts"
      ];

      # Ensure status path under XDG state exists to avoid first-run hiccups
      home.activation.vdirsyncerStateDir =
        config.lib.neg.mkEnsureDirsAfterWrite [
          "${config.xdg.stateHome or "$HOME/.local/state"}/vdirsyncer"
        ];
      systemd.user.services.vdirsyncer = lib.mkMerge [
        {
          Unit = { Description = "Vdirsyncer synchronization service"; };
          Service = {
            Type = "oneshot";
            ExecStartPre = "${lib.getExe pkgs.vdirsyncer} metasync";
            ExecStart = "${lib.getExe pkgs.vdirsyncer} sync";
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["netOnline"]; })
      ];

      systemd.user.timers.vdirsyncer = lib.mkMerge [
        {
          Unit = { Description = "Vdirsyncer synchronization timer"; };
          Timer = {
            OnBootSec = "2m";
            OnUnitActiveSec = "5m";
            Unit = "vdirsyncer.service";
          };
        }
        (config.lib.neg.systemdUser.mkUnitFromPresets { presets = ["timers"]; })
      ];
    }
    (let
       tpl = builtins.readFile ./config.tpl;
       stateHome = (config.xdg.stateHome or "$HOME/.local/state");
       home = config.home.homeDirectory;
       rendered = lib.replaceStrings ["@XDG_STATE@" "@HOME@"] [ stateHome home ] tpl;
     in xdg.mkXdgText "vdirsyncer/config" rendered)
  ])
