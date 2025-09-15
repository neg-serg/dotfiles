{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.gui.enable (let
    xdg = import ../../lib/xdg-helpers.nix { inherit lib; };
    rofiPkg = (pkgs.rofi.override {
      plugins = [
        pkgs.rofi-file-browser
        pkgs.neg.rofi_games
      ];
    });
    xdgDataHome = config.xdg.dataHome or ("${config.home.homeDirectory}/.local/share");
    xdgConfigHome = config.xdg.configHome or ("${config.home.homeDirectory}/.config");
    # Build theme link descriptors from a compact list of relative paths.
    themeFiles = [
      "theme.rasi"
      "common.rasi"
      "clip.rasi"
      "sxiv.rasi"
      "win/left_btm.rasi"
    ];
    themeLinks = map (rel: {
      dst = "rofi/themes/${rel}";
      src = "conf/${rel}";
    }) themeFiles;
  in lib.mkMerge ([
    {
      home.packages = with pkgs; config.lib.neg.pkgsList [
        rofi-pass-wayland # pass interface for rofi-wayland
        rofiPkg # modern dmenu alternative with plugins
        # cliphist is provided in gui/apps.nix; no need for greenclip/clipmenu
      ];
      
      # Wrap rofi to ensure '-theme <name|name.rasi>' works even when caller uses a relative theme path.
      # If a theme is given without a path, we `cd` into the themes directory so rofi finds the file.
      home.file.".local/bin/rofi" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          rofi_bin="${rofiPkg}/bin/rofi"
          jq_bin="${pkgs.jq}/bin/jq"
          hyprctl_bin="${pkgs.hyprland}/bin/hyprctl"
          xdg_data="${xdgDataHome}"
          xdg_conf="${config.xdg.configHome}"
          themes_dir="$xdg_data/rofi/themes"
          # Default to config dir to make @import in config.rasi resolve relative files
          cd_dir="$xdg_conf/rofi"
          prev_is_theme=0
          have_cfg=0
          want_offsets=1
          have_xoff=0; have_yoff=0; have_loc=0
          for arg in "$@"; do
            if [ "$prev_is_theme" -eq 1 ]; then
              val="$arg"
              prev_is_theme=0
              case "$val" in
                /*|*/*) : ;; # absolute or contains path component -> leave as-is
                *)
                  case "$val" in *.rasi|*.rasi:*) cd_dir="$themes_dir" ;; esac
                ;;
              esac
            fi
            case "$arg" in
              -theme) prev_is_theme=1 ;;
              -theme=*)
                val=$(printf '%s' "$arg" | sed -e 's/^-theme=//')
                case "$val" in
                  /*|*/*) : ;;
                  *) case "$val" in *.rasi|*.rasi:*) cd_dir="$themes_dir" ;; esac ;;
                esac
                ;;
              -no-config| -config| -config=*) have_cfg=1 ;;
              -xoffset| -xoffset=*) have_xoff=1 ;;
              -yoffset| -yoffset=*) have_yoff=1 ;;
              -location| -location=*) have_loc=1 ;;
            esac
          done
          [ -d "$cd_dir" ] && cd "$cd_dir"

          # Compute offsets from Quickshell Theme + Hyprland scale to align with panel
          # Only when caller did not specify offsets explicitly
          if [ "$want_offsets" -eq 1 ] && [ "$have_xoff" -eq 0 ] && [ "$have_yoff" -eq 0 ]; then
            theme_json="$HOME/.config/quickshell/Theme.json"
            # Defaults if quickshell or jq/hyprctl unavailable
            ph=28; sm=18; ay=4; scale=1
            if [ -f "$theme_json" ]; then
              ph=$("$jq_bin" -r 'try .panel.height // 28' "$theme_json" 2>/dev/null || echo 28)
              sm=$("$jq_bin" -r 'try .panel.sideMargin // 18' "$theme_json" 2>/dev/null || echo 18)
              ay=$("$jq_bin" -r 'try .panel.menuYOffset // 8' "$theme_json" 2>/dev/null || echo 8)
            fi
            # Hyprland monitor scale (focused)
            scale=$("$hyprctl_bin" -j monitors 2>/dev/null | "$jq_bin" -r 'try (.[ ] | select(.focused==true) | .scale) // 1' 2>/dev/null || echo 1)
            # Round offsets to ints
            xoff=$(printf '%.0f\n' "$(awk -v a="$sm" -v s="$scale" 'BEGIN{printf a*s}')")
            yoff=$(printf '%.0f\n' "$(awk -v a="$ay" -v s="$scale" 'BEGIN{printf -a*s}')")
            set -- "$@" -xoffset "$xoff" -yoffset "$yoff"
            # Ensure bottom-left if not specified
            if [ "$have_loc" -eq 0 ]; then
              set -- "$@" -location 7
            fi
          fi

          # Avoid parsing user/system config if not explicitly requested (rofi 2.0 parser is strict)
          if [ "$have_cfg" -eq 0 ]; then
            set -- -no-config "$@"
          fi
          exec "$rofi_bin" "$@"
        '';
      };

      
    }
    # Live-editable config via helper (guards parent dir and target)
    (xdg.mkXdgSource "rofi" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf" true))
  ]
  ++ (map (e: xdg.mkXdgDataSource e.dst (config.lib.neg.mkDotfilesSymlink ("nix/.config/home-manager/modules/user/gui/rofi/" + e.src) false)) themeLinks)
  ++ [{
    # Clean up leftovers from pre-refactor
    home.activation.cleanupRofiLeftovers =
      let ch = xdgConfigHome; d = xdgDataHome; in
      config.lib.neg.mkEnsureAbsentMany [
        "${d}/rofi/themes/win/center_btm.rasi"
        "${d}/rofi/themes/win/no_gap.rasi"
        "${d}/rofi/themes/neg.rasi"
        "${d}/rofi/themes/pass.rasi"
        "${ch}/rofimoji"
        "${d}/applications/rofimoji.desktop"
      ];
  }])
)
