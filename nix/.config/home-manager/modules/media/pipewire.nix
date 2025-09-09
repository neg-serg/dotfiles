{config, ...}: let
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = config.lib.neg.dotfilesRoot;
in {
  xdg.configFile = {
    "wireplumber" = {
      source = l "${dots}/media/.config/wireplumber";
      recursive = true;
    };
    "pipewire" = {
      source = l "${dots}/media/.config/pipewire";
      recursive = true;
    };
  };
}
