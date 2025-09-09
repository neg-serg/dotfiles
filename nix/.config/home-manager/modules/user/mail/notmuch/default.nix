{
  lib,
  config,
  ...
}:
with lib;
  mkIf config.features.mail.enable {
    programs.notmuch = {
      enable = true;
      new = {
        tags = ["unread" "inbox"];
        ignore = [];
      };
      search = {
        excludeTags = ["deleted" "spam"];
      };
      maildir = {
        synchronizeFlags = true;
      };
      extraConfig = {
        database = {
          path = "${config.home.homeDirectory}/.local/mail";
        };
      };
    };
    accounts.email.accounts."gmail".notmuch.enable = true;
  }
