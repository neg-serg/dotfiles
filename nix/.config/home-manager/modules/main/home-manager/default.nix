{ lib, config, ... }:
{
  programs = {
    home-manager.enable = true; # Let Home Manager install and manage itself.
  };

  # Remove stale ~/.config/home-manager symlink from older generations before linking
  home.activation.fixHomeManagerConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/home-manager";

  # Make the repo available at ~/.config/home-manager for convenience
  xdg.configFile."home-manager" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager" true;
}
