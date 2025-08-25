{
  pkgs,
  config,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  imports = [
    ./accounts
    ./imapnotify
    ./khal # better calendar
    ./msmtp
    ./notmuch
    # ./vdirsyncer
  ];
  home.packages = with pkgs; [
    himalaya # modern cli for mail
    kyotocabinet # mail client helper library
    neomutt # mail client
  ];
}
