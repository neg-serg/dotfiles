{ lib, config, ... }:
let
  l = config.lib.file.mkOutOfStoreSymlink;
  repoRustmissionConf = "${config.lib.neg.dotfilesRoot}/nix/.config/home-manager/modules/misc/rustmission/conf";
in {
  # Remove stale ~/.config/rustmission symlink before linking
  home.activation.fixRustmissionConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/rustmission";

  # Live-editable out-of-store symlink to repo copy
  xdg.configFile."rustmission" = {
    source = l repoRustmissionConf;
    recursive = true;
  };
}
