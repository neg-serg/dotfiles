{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.apps.enable (
  {
  home.packages = config.lib.neg.pkgsList [
      # codecs / ripping / players
      pkgs.ape pkgs.cdparanoia pkgs.cider
      # analysis
      pkgs.dr14_tmeter pkgs.essentia-extractor pkgs.opensoundmeter pkgs.sonic-visualiser pkgs.roomeqwizard
      # tagging
      pkgs.id3v2 pkgs.picard pkgs.unflac
      # cli
      pkgs.ncpamixer pkgs.sox
      # net
      pkgs.nicotine-plus pkgs.scdl pkgs.streamlink
      # misc
      pkgs.screenkey
  ];
  }
)
