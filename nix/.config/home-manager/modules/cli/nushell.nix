{ lib, config, pkgs, ... }:
{
  # Ensure Nushell is available
  home.packages = config.lib.neg.filterByExclude [ pkgs.nushell ];

  # Remove stale ~/.config/nushell symlink from older generations before linking
  home.activation.fixNuConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/nushell";

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."nushell" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/cli/nushell-conf" true;
}
