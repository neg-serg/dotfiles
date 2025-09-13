{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.gui.enable (let xdg = import ../../lib/xdg-helpers.nix { inherit lib; }; in lib.mkMerge [
    {
      home.packages = with pkgs; config.lib.neg.pkgsList [
        rofi-pass-wayland # pass interface for rofi-wayland
        (rofi.override {
          plugins = [
            rofi-file-browser # file browser plugin
            pkgs.neg.rofi_games # custom games launcher
          ];
        }) # modern dmenu alternative
        # cliphist is provided in gui/apps.nix; no need for greenclip/clipmenu
      ];
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
