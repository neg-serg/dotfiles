{ pkgs, lib, config, ... }:
lib.mkIf config.features.media.audio.apps.enable {
  home.packages = with pkgs; [
    ape # monkey audio codec
    cdparanoia # cdrip / cdrecord
    cider # apple music player
    dr14_tmeter # compute DR14 (PMF procedure)
    essentia-extractor # acousticBrainz audio feature extractor
    id3v2 # id3v2 edit
    ncpamixer # cli-pavucontrol
    nicotine-plus # download music via soulseek
    opensoundmeter # sound measurement application for tuning audio systems in real-time
    picard # autotags
    roomeqwizard # room acoustics software
    scdl # download music from soundcloud
    screenkey # screencast tool to display your keys inspired by Screenflick
    sonic-visualiser # audio analyzer
    sox # audio processing
    streamlink # CLI for extracting streams from websites
    unflac # split2flac alternative
    # Similarity scripts rely on your existing Python env from dev/python module
  ];
}
