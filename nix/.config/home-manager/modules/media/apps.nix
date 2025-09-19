{
  lib,
  config,
  pkgs,
  ...
}:
lib.mkIf (config.features.media.audio.apps.enable or false) {
  home.packages = config.lib.neg.pkgsList [
    pkgs.ffmpeg-full # famous multimedia lib
    pkgs.ffmpegthumbnailer # thumbnail for video
    pkgs.gmic # new framework for image processing
    pkgs.imagemagick # for convert
    pkgs.mediainfo # tag information about video or audio
    pkgs.media-player-info # repository of data files describing media player capabilities
    pkgs.neg.mkvcleaner # clean mkv files from useless data
    pkgs.mpvc # CLI controller for mpv
    pkgs.playerctl # media controller for everything
  ];
}
