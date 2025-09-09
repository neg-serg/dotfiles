{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./accounts
    ./isync
    ./imapnotify
    ./khal # better calendar
    ./msmtp
    ./notmuch
    ./vdirsyncer
  ];
  home.packages = with pkgs;
    lib.optionals config.features.mail [
      himalaya # modern cli for mail
      kyotocabinet # mail client helper library
      neomutt # mail client
    ];
}
