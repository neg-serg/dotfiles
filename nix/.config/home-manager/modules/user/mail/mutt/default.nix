{ lib, config, ... }:
with lib;
mkIf config.features.mail.enable {
  # Provide full mutt/neomutt configuration under XDG from embedded sources
  # This avoids any symlinks to ~/.dotfiles and keeps it HM-managed
  xdg.configFile."mutt".source = ./conf;
}
