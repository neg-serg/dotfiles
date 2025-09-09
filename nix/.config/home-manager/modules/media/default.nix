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
    ./audio
    ./images
    ./mpv.nix
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
  xdg.configFile = {
    "wireplumber" = {
      source = l "${dots}/media/.config/wireplumber";
      recursive = true;
    };
    "pipewire" = {
      source = l "${dots}/media/.config/pipewire";
      recursive = true;
    };
  };

  systemd.user.services = {
    playerctld = {
      Unit = {
        Description = "Keep track of media player activity";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.playerctl}/bin/playerctld daemon";
      };
      Install = {
        WantedBy = [
          "default.target" # start by default in user session
        ];
      };
    };
  };
}
