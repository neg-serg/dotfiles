{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
  mkIf config.features.gui.enable {
    home.packages = config.lib.neg.filterByExclude [pkgs.walker];

    # Remove stale ~/.config/walker symlink from older generations before linking
    home.activation.fixWalkerConfigDir =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/walker";

    # Live-editable config: out-of-store symlink to repo copy
    xdg.configFile."walker" =
      config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/walker/conf" true;
  }
