{ lib, config, pkgs, ... }:
lib.mkIf (config.features.media.audio.apps.enable or false) {
  home.packages =
    config.lib.neg.filterByExclude (with pkgs; [
      ffmpeg-full # famous multimedia lib
      ffmpegthumbnailer # thumbnail for video
      gmic # new framework for image processing
      imagemagick # for convert
      mediainfo # tag information about video or audio
      media-player-info # repository of data files describing media player capabilities
      pkgs.neg.mkvcleaner # clean mkv files from useless data
      mpvc # CLI controller for mpv
      playerctl # media controller for everything
    ]);
}
