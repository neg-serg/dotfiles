{
  lib,
  config,
  ...
}: {
  # Project-specific helpers under lib.neg
  config.lib.neg = {
    # mkEnabledList flags groups -> concatenated list of groups
    # flags: { a = true; b = false; }
    # groups: { a = [pkg1]; b = [pkg2]; }
    # => [pkg1]
    mkEnabledList = flags: groups: let
      names = builtins.attrNames groups;
    in
      lib.concatLists (
        builtins.map (n: lib.optionals (flags.${n} or false) (groups.${n} or [])) names
      );

    # Alias
    mkPackagesFromGroups = flags: groups: (config.lib.neg.mkEnabledList flags groups);

    # Emit a warning (non-fatal) when condition holds
    mkWarnIf = cond: msg: {
      warnings = lib.optional cond msg;
    };

    # Make an enable option with default value
    mkBool = desc: default:
      (lib.mkEnableOption desc) // {inherit default;};

    # Browser addons helper: produce well-known addon lists given NUR addons set
    browserAddons = fa: {
      common = with fa; [
        augmented-steam
        cookie-quick-manager
        darkreader
        enhanced-github
        export-tabs-urls-and-titles
        lovely-forks
        search-by-image
        stylus
        tabliss
        to-google-translate
        tridactyl
      ];
    };

    # Systemd (user) helpers to avoid repeating arrays in many modules
    systemdUser = let
      # Preset collections of common targets
      presets = {
        graphical = {
          after = ["graphical-session.target"];
          wants = ["graphical-session.target"];
          wantedBy = ["graphical-session.target"];
          partOf = [];
        };
        defaultWanted = {
          after = [];
          wants = [];
          wantedBy = ["default.target"];
          partOf = [];
        };
        timers = {
          after = [];
          wants = [];
          wantedBy = ["timers.target"];
          partOf = [];
        };
        net = {
          after = ["network.target"];
          wants = [];
          wantedBy = [];
          partOf = [];
        };
        netOnline = {
          after = ["network-online.target"];
          wants = ["network-online.target"];
          wantedBy = [];
          partOf = [];
        };
        sops = {
          after = ["sops-nix.service"];
          wants = ["sops-nix.service"];
          wantedBy = [];
          partOf = [];
        };
        dbusSocket = {
          after = ["dbus.socket"];
          wants = [];
          wantedBy = [];
          partOf = [];
        };
        socketsTarget = {
          after = ["sockets.target"];
          wants = [];
          wantedBy = [];
          partOf = [];
        };
      };
      # Merge preset array fields with optional extras and produce Unit/Install
      mkUnitFromPresets = args: let
        # args: { presets = ["graphical" "defaultWanted" ...]; after ? [], wants ? [], partOf ? [], wantedBy ? [] }
        names = args.presets or [];
        accum =
          lib.foldl'
          (acc: n: {
            after = acc.after ++ (presets.${n}.after or []);
            wants = acc.wants ++ (presets.${n}.wants or []);
            partOf = acc.partOf ++ (presets.${n}.partOf or []);
            wantedBy = acc.wantedBy ++ (presets.${n}.wantedBy or []);
          })
          {
            after = [];
            wants = [];
            partOf = [];
            wantedBy = [];
          }
          names;
        merged = {
          after = lib.unique (accum.after ++ (args.after or []));
          wants = lib.unique (accum.wants ++ (args.wants or []));
          partOf = lib.unique (accum.partOf ++ (args.partOf or []));
          wantedBy = lib.unique (accum.wantedBy ++ (args.wantedBy or []));
        };
      in {
        Unit =
          lib.optionalAttrs (merged.after != []) {After = merged.after;}
          // lib.optionalAttrs (merged.wants != []) {Wants = merged.wants;}
          // lib.optionalAttrs (merged.partOf != []) {PartOf = merged.partOf;};
        Install = lib.optionalAttrs (merged.wantedBy != []) {WantedBy = merged.wantedBy;};
      };
    in {
      inherit presets mkUnitFromPresets;
    };
  };
}
