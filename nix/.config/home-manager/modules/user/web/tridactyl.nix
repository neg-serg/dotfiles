{ lib, config, ... }:
with lib; let
  l = config.lib.file.mkOutOfStoreSymlink;
  # Use existing Tridactyl config stored in repo under misc/.config/tridactyl
  repoTridactylConf = "${config.lib.neg.dotfilesRoot}/misc/.config/tridactyl";
in mkIf config.features.web.enable {
  # Remove stale ~/.config/tridactyl symlink from older generations before linking
  home.activation.fixTridactylConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/tridactyl";

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."tridactyl" = {
    source = l repoTridactylConf;
    recursive = true;
  };
}
