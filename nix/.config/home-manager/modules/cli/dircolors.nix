{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  # Use existing dircolors config stored in repo under shell/.config/dircolors
  repoDircolorsConf = "${config.lib.neg.dotfilesRoot}/shell/.config/dircolors";
in {
  # Remove stale ~/.config/dircolors symlink from older generations before linking
  home.activation.fixDircolorsConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/dircolors";

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."dircolors" = {
    source = l repoDircolorsConf;
    recursive = true;
  };
}
