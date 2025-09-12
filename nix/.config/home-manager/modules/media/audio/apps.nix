{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.apps.enable (
  let
    groups = with pkgs; {
      codecs = [ape]; # monkey audio codec
      ripping = [cdparanoia]; # cdrip / cdrecord
      players = [cider]; # Apple Music player
      analysis = [
        dr14_tmeter # compute DR14 (PMF procedure)
        essentia-extractor # acousticBrainz audio feature extractor
        opensoundmeter # real-time tuning/measurement
        sonic-visualiser # audio analyzer
        roomeqwizard # room acoustics software
      ];
      tagging = [
        id3v2 # id3v2 edit
        picard # autotags
        unflac # split2flac alternative
      ];
      cli = [
        ncpamixer # cli-pavucontrol
        sox # audio processing
      ];
      net = [
        nicotine-plus # Soulseek client
        scdl # download from SoundCloud
        streamlink # extract streams from websites
      ];
      misc = [
        screenkey # show pressed keys during screencasts
      ];
    };
    # Enable all groups by default; can be refined later if needed
    flags = (builtins.listToAttrs (map (n: { name = n; value = true; }) (builtins.attrNames groups)));
  in {
    home.packages = config.lib.neg.filterByExclude (config.lib.neg.mkEnabledList flags groups);
  }
)
