{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.tools.enable) {
  programs.yt-dlp = {
    enable = true;
    package = pkgs.yt-dlp; # download from youtube and another sources
    settings = {
      downloader-args = "aria2c:'-c -x8 -s8 -k1M'";
      downloader = "aria2c";
      embed-metadata = true;
      embed-subs = true;
      embed-thumbnail = true;
      sub-langs = "all";
    };
  };
}
