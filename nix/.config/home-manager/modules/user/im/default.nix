{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    tdl # Telegram CLI downloader/uploader
    telegram-desktop # cloud-based IM client
    vesktop # alternative Discord client
  ];
}
