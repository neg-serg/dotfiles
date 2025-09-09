{
  lib,
  config,
  ...
}:
with lib;
  mkIf config.features.mail {
    services.imapnotify.enable = true;
    accounts.email.accounts."gmail" = {
      imapnotify = {
        enable = true;
        boxes = ["INBOX"];
        extraConfig = {
          host = "imap.gmail.com";
          port = 993;
          tls = true;
          tlsOptions = {
            "rejectUnauthorized" = false;
          };
          onNewMail = "~/.config/mutt/scripts/sync_mail";
          onNewMailPost = "";
        };
      };
    };
  }
