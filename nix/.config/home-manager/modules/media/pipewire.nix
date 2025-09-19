{ lib, config, ... }:
lib.mkIf (config.features.media.audio.core.enable or false) {
  xdg.configFile = {
    "wireplumber" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/media/.config/wireplumber";
      recursive = true;
    };
    "pipewire" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/media/.config/pipewire";
      recursive = true;
    };
  };
}
