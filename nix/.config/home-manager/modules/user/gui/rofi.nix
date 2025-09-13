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
    # xdgConfigHome kept for reference; not needed by the wrapper now
  in lib.mkMerge [
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
          xdg_data="${xdgDataHome}"
          xdg_conf="${config.xdg.configHome}"
          themes_dir="$xdg_data/rofi/themes"
          # Default to config dir to make @import in config.rasi resolve relative files
          cd_dir="$xdg_conf/rofi"
          need_cd=1
          prev_is_theme=0
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
            esac
          done
          if [ "$need_cd" -eq 1 ] && [ -d "$cd_dir" ]; then
            cd "$cd_dir"
          fi
          exec "$rofi_bin" "$@"
        '';
      };
    }
    # Live-editable config via helper (guards parent dir and target)
    (xdg.mkXdgSource "rofi" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf" true))
    # Make themes discoverable via -theme <name> too (for external scripts)
    (xdg.mkXdgDataSource "rofi/themes/neg.rasi" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf/neg.rasi" false))
    (xdg.mkXdgDataSource "rofi/themes/pass.rasi" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf/pass.rasi" false))
    (xdg.mkXdgDataSource "rofi/themes/theme.rasi" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf/theme.rasi" false))
    (xdg.mkXdgDataSource "rofi/themes/win/no_gap.rasi" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf/win/no_gap.rasi" false))
    (xdg.mkXdgDataSource "rofi/themes/win/center_btm.rasi" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf/win/center_btm.rasi" false))
  ])
