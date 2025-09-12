{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.gui.enable {
    # Remove stale ~/.config/rofi symlink from older generations before linking
    home.activation.fixRofiConfigDir =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/rofi";

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

    # Live-editable config: out-of-store symlink pointing to repo files
    xdg.configFile."rofi" =
      config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/rofi/conf" true;
  }
