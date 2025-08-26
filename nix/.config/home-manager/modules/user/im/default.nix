{pkgs, ...}: {
  home.packages = with pkgs; [
    tdl # telegram cli downloader/uploader
    telegram-desktop # famous cloud-based im
    vesktop # alternative discord client
  ];
}
