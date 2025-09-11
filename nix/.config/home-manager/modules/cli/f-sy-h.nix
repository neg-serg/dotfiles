{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  # Use existing f-sy-h styles stored in repo under shell/.config/f-sy-h
  repoFSyHConf = "${config.lib.neg.dotfilesRoot}/shell/.config/f-sy-h";
in {
  # Remove stale ~/.config/f-sy-h symlink from older generations before linking
  home.activation.fixFSyHConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/f-sy-h";

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."f-sy-h" = {
    source = l repoFSyHConf;
    recursive = true;
  };
}
