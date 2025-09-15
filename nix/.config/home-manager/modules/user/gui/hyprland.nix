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
    # Declarative workspaces list -> generates workspaces.conf
    workspaces = [
      { id = 1;  name = "︁ 𐌰:term";     var = "term"; }
      { id = 2;  name = " 𐌱:web";       var = "web"; }
      { id = 3;  name = " 𐌲:dev";       var = "dev"; }
      { id = 4;  name = " 𐌸:games";     var = "games"; }
      { id = 5;  name = " 𐌳:doc";       var = "doc"; }
      { id = 6;  name = " 𐌴:draw";      var = null; }
      { id = 7;  name = "✽ vid";         var = "vid"; }
      { id = 8;  name = "✽ 𐌶:obs";       var = "obs"; }
      { id = 9;  name = " 𐌷:pic";       var = "pic"; }
      { id = 10; name = " 𐌹:sys";       var = null; }
      { id = 11; name = " 𐌺:vm";        var = "vm"; }
      { id = 12; name = " 𐌻:wine";      var = "wine"; }
      { id = 13; name = " 𐌼:patchbay";  var = "patchbay"; }
      { id = 14; name = " 𐌽:daw";       var = "daw"; }
      { id = 15; name = "💾 𐌾:dw";        var = "dw"; }
      { id = 16; name = " 𐌿:keyboard";  var = "keyboard"; }
      { id = 17; name = " 𐍀:im";        var = "im"; }
      { id = 18; name = " 𐍁:remote";    var = "remote"; }
      { id = 19; name = " Ⲣ:notes";     var = "notes"; }
    ];
    workspacesConf = let
      wsLines = builtins.concatStringsSep "\n" (map (w: "workspace = ${toString w.id}, defaultName:${w.name}") workspaces);
    in ''
      ${wsLines}

      workspace = w[tv1], gapsout:0, gapsin:0
      workspace = f[1], gapsout:0, gapsin:0
      windowrule = bordersize 0, floating:0, onworkspace:w[tv1]
      windowrule = rounding 0, floating:0, onworkspace:w[tv1]
      windowrule = bordersize 0, floating:0, onworkspace:f[1]
      windowrule = rounding 0, floating:0, onworkspace:f[1]

      # swayimg
      windowrulev2 = float, class:^(swayimg)$
      windowrulev2 = size 1200 800, class:^(swayimg)$
      windowrulev2 = move 100 100, class:^(swayimg)$
      # special
      windowrulev2 = fullscreen, $pic
    '';
    # Routing rules are window rules; include them from rules.conf directly.
    routesConf = let
      routeLines = builtins.concatStringsSep "\n" (
        lib.filter (s: s != "") (
          map (
            w:
              if (w.var or null) != null
              then "windowrulev2 = workspace name:${w.name}, $" + w.var
              else ""
          ) workspaces
        )
      );
    in ''
      # routing
      windowrulev2 = noblur, $term
      ${routeLines}
    '';
    hyprWinList = pkgs.writeShellApplication {
      name = "hypr-win-list";
      runtimeInputs = [
        pkgs.jq
        pkgs.hyprland
        pkgs.gawk
        pkgs.coreutils
        pkgs.gnused
      ];
      text = ''
        set -euo pipefail
        # List windows from Hyprland and select via rofi; focus selected.
        prompt="Windows"

        clients_json="$(hyprctl -j clients 2>/dev/null || true)"
        [ -n "$clients_json" ] || exit 0
        workspaces_json="$(hyprctl -j workspaces 2>/dev/null || true)"

        list=$(jq -nr \
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

        sel=$(printf '%s\n' "$list" | rofi -dmenu -matching fuzzy -i -p "$prompt" -theme clip) || exit 0
        addr=$(printf '%s' "$sel" | awk -F '\t' '{print $NF}' | sed 's/^ *//')
        [ -n "$addr" ] || exit 0

        hyprctl dispatch focuswindow "address:$addr" >/dev/null 2>&1 || true
        hyprctl dispatch bringactivetotop >/dev/null 2>&1 || true
      '';
    };
    coreFiles = [
      "init.conf"
      "vars.conf"
      "classes.conf"
      "rules.conf"
      "bindings.conf"
      "autostart.conf"
      "pyprland.toml"
    ];
    bindingFiles = [
      "resize.conf"
      "apps.conf"
      "special.conf"
      "wallpaper.conf"
      "tiling.conf"
      "tiling-helpers.conf"
      "media.conf"
      "notify.conf"
      "misc.conf"
      "_resets.conf"
    ];
    mkHyprSource = rel: xdg.mkXdgSource ("hypr/" + rel) (config.lib.neg.mkDotfilesSymlink ("nix/.config/home-manager/modules/user/gui/hypr/conf/" + rel) false);
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
      # Package groups flattened via mkEnabledList
      home.packages = with pkgs;
        config.lib.neg.pkgsList (
          let
            groups = {
              core = [
                hyprcursor # modern cursor theme format (replaces xcursor)
                hypridle # idle daemon
                hyprpicker # color picker
                hyprpolkitagent # polkit agent
                hyprprop # xprop-like tool for Hyprland
                hyprutils # core utils for Hyprland
                pyprland # Hyprland plugin system
                upower # power management daemon
              ];
              qt = [
                hyprland-qt-support # Qt integration fixes
                hyprland-qtutils # Hyprland Qt helpers
                kdePackages.qt6ct # Qt6 config tool
              ];
              tools = [ hyprWinList ];
            };
            flags = {
              core = true;
              tools = true;
              qt = config.features.gui.qt.enable;
            };
          in config.lib.neg.mkEnabledList flags groups
        );
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
    # Core configs
    (lib.mkMerge (map mkHyprSource coreFiles))
    # Generated workspaces (names, specials)
    (xdg.mkXdgText "hypr/workspaces.conf" workspacesConf)
    # Generated routing rules, sourced from rules.conf
    (xdg.mkXdgText "hypr/rules-routing.conf" routesConf)
    # Submaps and binding helpers
    (lib.mkMerge (map (f: mkHyprSource ("bindings/" + f)) bindingFiles))
    # Tools: window switcher using rofi
    { }
  ])
