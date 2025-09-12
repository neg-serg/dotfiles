{
  lib,
  config,
  ...
}:
with lib;
  mkIf config.features.mail.enable {
    # Remove stale ~/.config/mutt symlink from older generations before linking
    home.activation.fixMuttConfigDir =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/mutt";

    # Provide full mutt/neomutt configuration under XDG from embedded sources
    # This avoids any symlinks to ~/.dotfiles and keeps it HM-managed
    xdg.configFile."mutt".source = ./conf;
  }
