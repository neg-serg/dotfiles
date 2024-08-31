{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    ape # monkey audio codec
    audiowaveform # shows soundwaveform
    cdparanoia # cdrip / cdrecord
    cider # apple music player
    dr14_tmeter # compute the DR14 of a given audio file according to the procedure from Pleasurize Music Foundation
    id3v2 # id3v2 edit
    ncpamixer # cli-pavucontrol
    nicotine-plus # download music via soulseek
    opensoundmeter # sound measurement application for tuning audio systems in real-time
    picard # autotags
    roomeqwizard # room acoustics software
    screenkey # screencast tool to display your keys inspired by Screenflick
    sonic-visualiser # audio analyzer
    sox # audio processing
    streamlink # CLI for extracting streams from websites
    tauon # fancy standalone music player
    unflac # split2flac alternative
  ];
}
