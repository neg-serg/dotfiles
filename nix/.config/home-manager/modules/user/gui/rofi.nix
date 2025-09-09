{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoRofiConf = "${config.lib.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/rofi/conf";
in
  mkIf config.features.gui.enable {
    # Remove stale ~/.config/rofi symlink from older generations before linking
    home.activation.fixRofiConfigDir =
      lib.hm.dag.entryBefore [ "linkGeneration" ] ''
        set -eu
        RDIR="${config.xdg.configHome}/rofi"
        if [ -L "$RDIR" ]; then
          rm -f "$RDIR"
        fi
      '';

    home.packages = with pkgs; [
      rofi-pass-wayland # pass interface for rofi-wayland
      (rofi-wayland.override {
        plugins = [
          rofi-file-browser # file browser plugin
          pkgs.neg.rofi_games # custom games launcher
        ];
      }) # modern dmenu alternative
    ];

    # Live-editable config: out-of-store symlink pointing to repo files
    xdg.configFile."rofi" = {
      source = l repoRofiConf;
      recursive = true;
    };
  }
