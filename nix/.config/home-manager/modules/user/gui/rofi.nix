{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.gui.enable (let xdg = import ../../lib/xdg-helpers.nix { inherit lib; }; in lib.mkMerge [
    {
      home.packages = config.lib.neg.filterByExclude (with pkgs; [
        rofi-pass-wayland # pass interface for rofi-wayland
        (rofi.override {
          plugins = [
            rofi-file-browser # file browser plugin
            pkgs.neg.rofi_games # custom games launcher
          ];
        }) # modern dmenu alternative
        # cliphist is provided in gui/apps.nix; no need for greenclip/clipmenu
      ]);
    }
    # Live-editable config via helper (guards parent dir and target)
    (xdg.mkXdgSource "rofi" (config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf" true))
  ])
