{
  lib,
  config,
  ...
}:
with lib;
  mkIf config.features.web.enable {
    # Remove stale ~/.config/tridactyl symlink from older generations before linking
    home.activation.fixTridactylConfigDir =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/tridactyl";

    # Live-editable config: out-of-store symlink to repo copy
    xdg.configFile."tridactyl" =
      config.lib.neg.mkDotfilesSymlink "misc/.config/tridactyl" true;
  }
