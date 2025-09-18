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
  home.packages =
    config.lib.neg.pkgsList (
      let
        groups = with pkgs; {
          core = [
            himalaya # modern cli for mail
            kyotocabinet # mail client helper library
            neomutt # mail client
          ];
        };
        flags = { core = config.features.mail.enable or false; };
      in config.lib.neg.mkEnabledList flags groups
    );
}
