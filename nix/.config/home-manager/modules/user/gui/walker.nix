{ lib, config, pkgs, ... }:
with lib;
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoWalkerConf = "${config.lib.neg.dotfilesRoot}/nix/.config/home-manager/modules/user/gui/walker/conf";
in
  mkIf config.features.gui.enable {
    home.packages = [ pkgs.walker ];

    # Remove stale ~/.config/walker symlink from older generations before linking
    home.activation.fixWalkerConfigDir =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/walker";

    # Live-editable config: out-of-store symlink to repo copy
    xdg.configFile."walker" = {
      source = l repoWalkerConf;
      recursive = true;
    };
  }
