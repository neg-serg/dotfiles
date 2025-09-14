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
    coreFiles = [
      "init.conf"
      "vars.conf"
      "classes.conf"
      "rules.conf"
      "bindings.conf"
      "autostart.conf"
      "workspaces.conf"
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
    # Core configs
    (lib.mkMerge (map mkHyprSource coreFiles))
    # Submaps and binding helpers
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

          data="$($hyprctl_bin -j clients 2>/dev/null || true)"
          [ -n "$data" ] || exit 0

          list=$(printf '%s' "$data" | "$jq_bin" -r '[ .[] | select(.mapped==true) | [(.workspace.id|tostring), .class, .title, .address] ] | sort_by(.[0]) | .[] | "[\(.0)] \(.1) - \(.2)\t\(.3)"')
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
      home.file."bin/hypr-win-list" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          exec "${config.home.homeDirectory}/.local/bin/hypr-win-list" "$@"
        '';
      };
    }
  ])
