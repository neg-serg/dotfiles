{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./accounts
    ./isync
    ./mutt
    ./khal # better calendar
    ./msmtp
    ./notmuch
    ./vdirsyncer
  ];
  home.packages = config.lib.neg.filterByExclude (with pkgs;
    lib.optionals config.features.mail.enable [
      himalaya # modern cli for mail
      kyotocabinet # mail client helper library
      neomutt # mail client
    ]);
}
