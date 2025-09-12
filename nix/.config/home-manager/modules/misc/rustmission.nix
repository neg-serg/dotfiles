{
  lib,
  config,
  ...
}: {
  # Remove stale ~/.config/rustmission symlink before linking
  home.activation.fixRustmissionConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/rustmission";

  # Live-editable out-of-store symlink to repo copy
  xdg.configFile."rustmission" =
    config.lib.neg.mkDotfilesSymlink "nix/.config/home-manager/modules/misc/rustmission/conf" true;
}
