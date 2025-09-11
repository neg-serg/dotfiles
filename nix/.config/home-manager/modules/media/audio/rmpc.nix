{ lib, config, pkgs, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoRmpcConf = "${config.lib.neg.dotfilesRoot}/nix/.config/home-manager/modules/media/audio/rmpc/conf";
in {
  # Ensure rmpc is installed
  home.packages = [ pkgs.rmpc ];

  # Remove stale ~/.config/rmpc symlink from older generations, then link live
  home.activation.fixRmpcConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/rmpc";

  xdg.configFile."rmpc" = {
    source = l repoRmpcConf;
    recursive = true;
  };
}
