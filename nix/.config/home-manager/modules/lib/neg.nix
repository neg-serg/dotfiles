{
  lib,
  pkgs,
  config,
  ...
}: {
  # Project-specific helpers under lib.neg
  config.lib.neg = {
    # Configurable root of your dotfiles repository (see options.neg.dotfilesRoot)

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

    # Package list helpers
    pnameOf = pkg: (pkg.pname or (builtins.parseDrvName (pkg.name or "")).name);
    filterByNames = names: pkgsList:
      builtins.filter (p: !(builtins.elem (config.lib.neg.pnameOf p) names)) pkgsList;
    filterByExclude = pkgsList:
      config.lib.neg.filterByNames (config.features.excludePkgs or []) pkgsList;

    # Shorthand: apply global excludePkgs filter to a list of packages
    # Usage:
    #   home.packages = with pkgs; config.lib.neg.pkgsList [ foo bar ];
    pkgsList = xs: config.lib.neg.filterByExclude xs;

    # Emit a warning (non-fatal) when condition holds
    mkWarnIf = cond: msg: {
      warnings = lib.optional cond msg;
    };

    # Make an enable option with default value
    mkBool = desc: default:
      (lib.mkEnableOption desc) // {inherit default;};

    # Create a Home Manager home.file symlink from dotfilesRoot
    # Usage: config.lib.neg.mkDotfilesSymlink "path/in/repo" false
    mkDotfilesSymlink = path: recursive: {
      source = config.lib.file.mkOutOfStoreSymlink "${config.lib.neg.dotfilesRoot}/${path}";
      inherit recursive;
    };

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

    # Web helpers defaults
    # Provide a safe fallback default browser so modules can refer to
    # config.lib.neg.web.defaultBrowser even when features.web.enable = false.
    web.defaultBrowser = lib.mkDefault {
      name = "xdg-open";
      pkg = pkgs.xdg-utils;
      bin = "${pkgs.xdg-utils}/bin/xdg-open";
      desktop = "xdg-open.desktop";
      newTabArg = "";
    };

    # Home activation DAG helpers to avoid repeating small shell snippets
    # Usage patterns:
    #   home.activation.fixZsh = config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/zsh";
    #   home.activation.fixGdbDir = config.lib.neg.mkEnsureRealDir "${config.xdg.configHome}/gdb";
    #   home.activation.fixTigFile = config.lib.neg.mkRemoveIfNotSymlink "${config.xdg.configHome}/tig/config";
    mkRemoveIfSymlink = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -L "${path}" ]; then
          rm -f "${path}"
        fi
      '';

    # Remove the path only if it is a broken symlink (preserve valid symlinks)
    mkRemoveIfBrokenSymlink = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -L "${path}" ] && [ ! -e "${path}" ]; then
          rm -f "${path}"
        fi
      '';

    mkEnsureRealDir = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -L "${path}" ]; then
          rm -f "${path}"
        fi
        mkdir -p "${path}"
      '';

    # Ensure multiple directories exist before linkGeneration and are real dirs (not symlinks)
    # For each path: if path is a symlink, remove it, then mkdir -p path
    mkEnsureRealDirsMany = paths: let
      quoted = lib.concatStringsSep " " (map (p: "\"" + p + "\"") paths);
    in
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        for p in ${quoted}; do
          if [ -L "$p" ]; then
            rm -f "$p"
          fi
          mkdir -p "$p"
        done
      '';

    mkRemoveIfNotSymlink = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -e "${path}" ] && [ ! -L "${path}" ]; then
          rm -f "${path}"
        fi
      '';

    # Ensure directories exist after HM writes files
    # Useful for app runtime dirs that must be present before services start.
    mkEnsureDirsAfterWrite = paths: let
      quoted = lib.concatStringsSep " " (map (p: "\"" + p + "\"") paths);
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        set -eu
        mkdir -p ${quoted}
      '';

    # Ensure a set of Maildir-style folders exist under a base path.
    # Example: mkEnsureMaildirs "$HOME/.local/mail/gmail" ["INBOX" "[Gmail]/Sent Mail" ...]
    mkEnsureMaildirs = base: boxes: let
      mkLine = b: ''mkdir -p "${base}/${b}/cur" "${base}/${b}/new" "${base}/${b}/tmp"'';
      body = lib.concatStringsSep "\n" (map mkLine boxes);
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''
        set -eu
        ${body}
      '';

    # Ensure a path is absent before HM links/writes files.
    # Removes regular files with rm -f and directories with rm -rf, ignores symlinks
    # (combine with mkRemoveIfSymlink if needed).
    mkEnsureAbsent = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        if [ -e "${path}" ] && [ ! -L "${path}" ]; then
          if [ -d "${path}" ]; then
            rm -rf "${path}"
          else
            rm -f "${path}"
          fi
        fi
      '';

    mkEnsureAbsentMany = paths: let
      scriptFor = p: ''
        if [ -e "${p}" ] && [ ! -L "${p}" ]; then
          if [ -d "${p}" ]; then rm -rf "${p}"; else rm -f "${p}"; fi
        fi
      '';
      body = lib.concatStringsSep "\n" (map scriptFor paths);
    in
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        ${body}
      '';

    # Ensure the parent directory of a path is a real directory (not a symlink)
    # and exists. Uses dirname at runtime to avoid brittle string parsing in Nix.
    mkEnsureRealParent = path:
      lib.hm.dag.entryBefore ["linkGeneration"] ''
        set -eu
        parent_dir="$(dirname "${path}")"
        if [ -L "$parent_dir" ]; then
          rm -f "$parent_dir"
        fi
        mkdir -p "$parent_dir"
      '';

    # XDG file helpers were split into a dedicated pure helper module
    # to avoid config/lib coupling in regular modules. Prefer importing
    # modules/lib/xdg-helpers.nix locally where needed:
    #   let xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
    #   in xdg.mkXdgText "path/in/config" "...contents..."
    # See STYLE.md ("XDG file helpers") for examples and guidance.
  };

  # Provide a typed option for dotfiles root, and mirror it under lib.neg
  options.neg.dotfilesRoot = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/.dotfiles";
    description = "Path to the root of the user's dotfiles repository.";
    example = "/home/neg/.cfg";
  };

  config.lib.neg.dotfilesRoot = config.neg.dotfilesRoot;
}
