{
  lib,
  config,
  ...
}: {
  # Remove stale ~/.config/kitty symlink from older generations before linking
  home.activation.fixKittyConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/kitty";

  # Live-editable config: out-of-store symlink to repo copy
  xdg.configFile."kitty" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/user/gui/kitty/conf" true;
}
