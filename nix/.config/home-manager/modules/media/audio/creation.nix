{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.creation.enable {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    bespokesynth # nice modular synth
    dexed # nice yamaha dx7-like fm synth
    noisetorch # virtual microphone to suppress the noise
    ocenaudio # good audio editor
    reaper # DAW (Reaper)
    rnnoise # neural network noise reduction
    stochas # nice free sequencer
    vcv-rack # powerful soft modular synth
    vital # serum-like digital synth
  ];
}
