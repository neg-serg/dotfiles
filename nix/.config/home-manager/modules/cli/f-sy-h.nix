{ lib, config, ... }:
{
  # Remove stale ~/.config/f-sy-h symlink from older generations before linking
  home.activation.fixFSyHConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/f-sy-h";

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."f-sy-h" = config.lib.neg.mkDotfilesSymlink "shell/.config/f-sy-h" true;
}
