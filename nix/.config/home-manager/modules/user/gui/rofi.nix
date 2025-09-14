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
    themeLinks = [
      { dst = "rofi/themes/theme.rasi";       src = "conf/theme.rasi"; }
      { dst = "rofi/themes/clip.rasi";        src = "conf/clip.rasi"; }
      { dst = "rofi/themes/sxiv.rasi";        src = "conf/sxiv.rasi"; }
      { dst = "rofi/themes/win/left_btm.rasi"; src = "conf/win/left_btm.rasi"; }
    ];
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

      # Compatibility shim: map fuzzel calls to rofi -dmenu with sensible defaults.
      home.file.".local/bin/fuzzel" = {
        executable = true;
        text = ''
          #!/usr/bin/env bash
          set -euo pipefail
          rofi_wrap="$HOME/.local/bin/rofi"
          rofi_bin="${rofiPkg}/bin/rofi"
          if [ -x "$rofi_wrap" ]; then rofi_cmd="$rofi_wrap"; else rofi_cmd="$rofi_bin"; fi
          args=("-dmenu" "-matching" "fuzzy" "-i" "-theme" "clip")
          prev=""
          for a in "$@"; do
            case "$a" in
              --dmenu|-d) : ;; # skip, already added
              --prompt=*) args+=("-p" "${a#--prompt=}") ;;
              --prompt) prev="--prompt" ;;
              --config=*) args+=("-config" "${a#--config=}") ;;
              --config) prev="--config" ;;
              *)
                if [ "$prev" = "--prompt" ]; then args+=("-p" "$a"); prev="";
                elif [ "$prev" = "--config" ]; then args+=("-config" "$a"); prev="";
                else args+=("$a"); fi ;;
            esac
          done
          exec "$rofi_cmd" "${args[@]}"
        '';
      };
    }
    # Live-editable config via helper (guards parent dir and target)
    (xdg.mkXdgSource "rofi" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf" true))
  ]
  ++ (map (e: xdg.mkXdgDataSource e.dst (config.lib.neg.mkDotfilesSymlink ("nix/.config/home-manager/modules/user/gui/rofi/" + e.src) false)) themeLinks)
  ++ [
    {
      # Clean up old unmanaged XDG data theme fragments from pre-refactor
      home.activation.cleanupOldRofiWinThemes =
        let d = xdgDataHome; in
        config.lib.neg.mkEnsureAbsentMany [
          "${d}/rofi/themes/win/center_btm.rasi"
          "${d}/rofi/themes/win/no_gap.rasi"
        ];
    }
    {
      # Clean up old neg/pass themes from XDG data to avoid Skipping delete messages
      home.activation.cleanupOldRofiNegPassThemes =
        let d = xdgDataHome; in
        config.lib.neg.mkEnsureAbsentMany [
          "${d}/rofi/themes/neg.rasi"
          "${d}/rofi/themes/pass.rasi"
        ];
    }
    {
      # Remove leftovers from old launchers
      home.activation.cleanupOldLaunchers =
        let ch = xdgConfigHome; dh = xdgDataHome; in
        config.lib.neg.mkEnsureAbsentMany [
          "${ch}/rofimoji"
          "${dh}/applications/rofimoji.desktop"
        ];
    }
  ])
)
