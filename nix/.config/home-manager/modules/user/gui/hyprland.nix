{
  lib,
  config,
  pkgs,
  hy3,
  ...
}:
with lib; let
  hy3Plugin = hy3.packages.${pkgs.system}.hy3;
  xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
in
  mkIf config.features.gui.enable (let
    confRoot = ./hypr/conf;
    mkHyprSource = rel: xdg.mkXdgSource ("hypr/" + rel) (config.lib.neg.mkDotfilesSymlink ("nix/.config/home-manager/modules/user/gui/hypr/conf/" + rel) false);
    # Auto-discover root-level files (*.conf, *.toml)
    rootFiles = let
      listing = builtins.readDir confRoot;
      names = builtins.attrNames listing;
      isWanted = n:
        let t = listing.${n}.type; in
        t == "regular" && (lib.hasSuffix ".conf" n || lib.hasSuffix ".toml" n);
    in builtins.sort (a: b: a < b) (builtins.filter isWanted names);
    # Auto-discover bindings/*.conf
    bindingFiles = let
      bdir = confRoot + "/bindings";
      listing = builtins.readDir bdir;
      names = builtins.attrNames listing;
      isWanted = n: listing.${n}.type == "regular" && lib.hasSuffix ".conf" n;
    in builtins.sort (a: b: a < b) (builtins.filter isWanted names);
  in lib.mkMerge [
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        settings = {
          # Load permissions first, then the main init
          source = [
            "${config.xdg.configHome}/hypr/permissions.conf"
            "${config.xdg.configHome}/hypr/init.conf"
          ];
        };
        systemd.variables = ["--all"];
      };
      home.packages = with pkgs; config.lib.neg.pkgsList [
        hyprcursor # modern cursor theme format (replaces xcursor)
        hypridle # idle daemon
        hyprland-qt-support # Qt integration fixes
        hyprland-qtutils # Hyprland Qt helpers
        hyprpicker # color picker
        hyprpolkitagent # polkit agent
        hyprprop # xprop-like tool for Hyprland
        hyprutils # core utils for Hyprland
        kdePackages.qt6ct # Qt6 config tool
        pyprland # Hyprland plugin system
        upower # power management daemon
      ];
      programs.hyprlock.enable = true;
    }
    # Ensure Hyprland reload happens after all files are linked/written, to avoid
    # a brief window where configs are absent (which could trigger prompts/crashes).
    # Add guards + diagnostics to avoid reloading into an "empty" config if includes
    # are not yet in place and to help identify the root cause.
    # NOTE: Automatic Hyprland reload on activation is disabled intentionally
    # to avoid crashes / empty-config states. Reload should be manual only.
    # Live-editable Hyprland configuration (safe guards via helper)
    # Permissions + plugin load prelude (ensures correct order on first start)
    (xdg.mkXdgText "hypr/permissions.conf" ''
      ecosystem {
        enforce_permissions = 1
      }
      permission = ${hy3Plugin}/lib/libhy3.so, plugin, allow
      permission = ${pkgs.grim}/bin/grim, screencopy, allow
      permission = ${pkgs.hyprlock}/bin/hyprlock, screencopy, allow
      plugin = ${hy3Plugin}/lib/libhy3.so
    '')
    # Core configs (auto-discovered)
    (lib.mkMerge (map mkHyprSource rootFiles))
    # Submaps and binding helpers (auto-discovered)
    (lib.mkMerge (map (f: mkHyprSource ("bindings/" + f)) bindingFiles))
    # Tools: window switcher using rofi
    {
      home.file.".local/bin/hypr-win-list" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          # List windows from Hyprland and select via rofi; focus selected.
          jq_bin="${pkgs.jq}/bin/jq"
          hyprctl_bin="hyprctl"
          rofi_bin="rofi"
          prompt="Windows"

          clients_json="$($hyprctl_bin -j clients 2>/dev/null || true)"
          [ -n "$clients_json" ] || exit 0
          workspaces_json="$($hyprctl_bin -j workspaces 2>/dev/null || true)"

          list=$("$jq_bin" -nr \
            --argjson clients "$clients_json" \
            --argjson wss "''${workspaces_json:-[]}" '
              def sanitize: tostring | gsub("[\t\n]"; " ");
              # Build id->name map
              def wmap:
                reduce $wss[] as $w ({}; .[($w.id|tostring)] = (($w.name // ($w.id|tostring))|tostring));
              . as $in
              | ($in | wmap) as $wm
              | [ $clients[]
                  | select(.mapped==true)
                  | {wid: (.workspace.id|tostring),
                     wname: ($wm[.workspace.id|tostring] // (.workspace.id|tostring)),
                     cls: (.class // ""),
                     ttl: (.title // ""),
                     addr: (.address // "")}
                ]
              | sort_by(.wid)
              | .[]
              | ("[" + (.wname|sanitize) + "] "
                 + (.cls|sanitize)
                 + " - "
                 + (.ttl|sanitize)
                 + "\t"
                 + .addr)
            ')
          [ -n "$list" ] || exit 0

          sel=$(printf '%s\n' "$list" | "$rofi_bin" -dmenu -matching fuzzy -i -p "$prompt" -theme clip) || exit 0
          addr=$(printf '%s' "$sel" | awk -F '\t' '{print $NF}' | sed 's/^ *//')
          [ -n "$addr" ] || exit 0

          $hyprctl_bin dispatch focuswindow "address:$addr" >/dev/null 2>&1 || true
          $hyprctl_bin dispatch bringactivetotop >/dev/null 2>&1 || true
        '';
      };
      # Ensure legacy ~/bin script is replaced with our wrapper for PATH stability
      home.activation.removeOldHyprWinList =
        config.lib.neg.mkEnsureAbsent "${config.home.homeDirectory}/bin/hypr-win-list";
      # Link wrapper into ~/bin for compatibility
      home.activation.linkHyprWinListWrapper = lib.hm.dag.entryAfter ["writeBoundary"] ''
        set -eu
        mkdir -p "$HOME/bin"
        ln -sf "$HOME/.local/bin/hypr-win-list" "$HOME/bin/hypr-win-list"
      '';
    }
  ])
