{
  lib,
  config,
  pkgs,
  ...
}: {
  # Ensure rmpc is installed
  home.packages = config.lib.neg.filterByExclude [pkgs.rmpc];

  # Remove stale ~/.config/rmpc symlink from older generations, then link live
  home.activation.fixRmpcConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/rmpc";

  xdg.configFile."rmpc" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/media/audio/rmpc/conf" true;
}
