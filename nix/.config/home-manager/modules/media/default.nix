{
  pkgs,
  config,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = config.lib.neg.dotfilesRoot;
}; {
  imports = [
    ./audio
    ./images
    ./mpv.nix
    ./pipewire.nix
    ./playerctld.nix
  ];
  home.packages = with pkgs; [
    ffmpeg-full # famous multimedia lib
    ffmpegthumbnailer # thumbnail for video
    gmic # new framework for image processing
    imagemagick # for convert
    mediainfo # tag information about video or audio
    media-player-info # repository of data files describing media player capabilities
    pkgs.neg.mkvcleaner # clean mkv files from useless data
    mpvc # CLI controller for mpv
    playerctl # media controller for everything
  ];
  # moved to playerctld.nix and pipewire.nix
}
