{
  lib,
  config,
  ...
}: {
  # Remove stale ~/.config/dircolors symlink from older generations before linking
  home.activation.fixDircolorsConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/dircolors";

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."dircolors" = config.lib.neg.mkDotfilesSymlink "shell/.config/dircolors" true;
}
