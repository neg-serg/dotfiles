{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.tdl # Telegram CLI downloader/uploader
    pkgs.telegram-desktop # cloud-based IM client
    pkgs.vesktop # alternative Discord client
  ];
}
