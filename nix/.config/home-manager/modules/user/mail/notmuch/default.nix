{...}: {
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
        path = "/home/neg/.local/mail";
      };
    };
  };
  accounts.email.accounts."gmail".notmuch.enable = true;
}
