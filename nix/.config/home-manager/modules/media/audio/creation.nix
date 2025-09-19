{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.creation.enable {
  home.packages = config.lib.neg.pkgsList [
    pkgs.bespokesynth # nice modular synth
    pkgs.dexed # nice yamaha dx7-like fm synth
    pkgs.noisetorch # virtual microphone to suppress the noise
    pkgs.ocenaudio # good audio editor
    pkgs.reaper # DAW (Reaper)
    pkgs.rnnoise # neural network noise reduction
    pkgs.stochas # nice free sequencer
    pkgs.vcv-rack # powerful soft modular synth
    pkgs.vital # serum-like digital synth
  ];
}
