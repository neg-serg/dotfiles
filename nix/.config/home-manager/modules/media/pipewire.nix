{config, ...}: {
  xdg.configFile = {
    "wireplumber" = config.lib.neg.mkDotfilesSymlink "media/.config/wireplumber" true;
    "pipewire" = config.lib.neg.mkDotfilesSymlink "media/.config/pipewire" true;
  };
}
