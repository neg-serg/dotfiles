{pkgs, ...}: {
  home.packages = with pkgs; [
    tdl # Telegram CLI downloader/uploader
    telegram-desktop # cloud-based IM client
    vesktop # alternative Discord client
  ];
}
