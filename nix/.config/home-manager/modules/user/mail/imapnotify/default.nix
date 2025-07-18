{...}: {
  services.imapnotify.enable = false;
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
