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
  mkIf config.features.gui.enable (lib.mkMerge [
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
      home.packages = config.lib.neg.filterByExclude (with pkgs; [
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
      ]);
      programs.hyprlock.enable = true;
    }
    # Ensure Hyprland reload happens after all files are linked/written, to avoid
    # a brief window where configs are absent (which could trigger prompts/crashes).
    # Add guards + diagnostics to avoid reloading into an "empty" config if includes
    # are not yet in place and to help identify the root cause.
    {
      home.activation.hyprlandSafeReload = lib.hm.dag.entryAfter ["linkGeneration"] ''
        set -eu
        cfg_dir="${config.xdg.configHome}/hypr"
        main_cfg="$cfg_dir/hyprland.conf"

        log() { printf "%s\n" "$*"; }

        # Collect basic diagnostics for troubleshooting
        if [ -e "$main_cfg" ]; then
          log "[hyprlandSafeReload] main config present: $main_cfg"
        else
          log "[hyprlandSafeReload] main config MISSING: $main_cfg"
        fi

        # Verify that sources referenced from the main config resolve and are non-empty
        # (best-effort: only checks obvious source lines)
        src_missing=0
        if [ -e "$main_cfg" ]; then
          while IFS= read -r line; do
            case "$line" in
              source*=*)
                src="''${line#*=}"
                # Trim possible surrounding spaces
                src="''${src# }"; src="''${src% }"
                # Expand ~ for our test
                eval src_expanded="$src"
                if [ ! -s "$src_expanded" ]; then
                  log "[hyprlandSafeReload] include missing/empty: $src_expanded (from: $line)"
                  src_missing=1
                fi
                ;;
            esac
          done < "$main_cfg"
        fi

        # If Hyprland isn't reachable, skip silently
        if command -v hyprctl >/dev/null 2>&1; then
          if hyprctl -j monitors >/dev/null 2>&1; then
            # Optional: validate the config syntax via Hyprland itself if available
            if command -v hyprland >/dev/null 2>&1; then
              if ! hyprland --verify-config --config "$main_cfg" >/dev/null 2>&1; then
                log "[hyprlandSafeReload] hyprland --verify-config failed, skipping reload"
                exit 0
              fi
            fi

            # If includes look missing, wait briefly to avoid a race, then re-check once
            if [ "$src_missing" -ne 0 ]; then
              sleep 0.75
              src_missing=0
              if [ -e "$main_cfg" ]; then
                while IFS= read -r line; do
                  case "$line" in
                    source*=*)
                      src="''${line#*=}"
                      src="''${src# }"; src="''${src% }"
                      eval src_expanded="$src"
                      if [ ! -s "$src_expanded" ]; then
                        src_missing=1
                      fi
                      ;;
                  esac
                done < "$main_cfg"
              fi
            fi

            if [ "$src_missing" -eq 0 ]; then
              # Perform reload; keep stderr for troubleshooting but not too noisy
              hyprctl reload 2>&1 || true
              log "[hyprlandSafeReload] hyprctl reload requested"
            else
              log "[hyprlandSafeReload] skipped reload: includes missing"
            fi
          fi
        fi
      '';
    }
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
    (xdg.mkXdgSource "hypr/init.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/init.conf" false))
    (xdg.mkXdgSource "hypr/rules.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/rules.conf" false))
    (xdg.mkXdgSource "hypr/bindings.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/bindings.conf" false))
    (xdg.mkXdgSource "hypr/autostart.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/autostart.conf" false))
    (xdg.mkXdgSource "hypr/workspaces.conf" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/workspaces.conf" false))
    (xdg.mkXdgSource "hypr/pyprland.toml" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/hypr/conf/pyprland.toml" false))
  ])
