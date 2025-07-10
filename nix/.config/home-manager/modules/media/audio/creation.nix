{pkgs, ...}: {
  home.packages = with pkgs; [
    bespokesynth # nice modular synth
    dexed # nice yamaha dx7-like fm synth
    noisetorch # virtual microphone to suppress the noise
    # ocenaudio # good audio editor
    reaper # А вот в рипере!
    rnnoise # neural network noise reduction
    stochas # nice free sequencer
    sunvox # fast and powerful modular synthesizer with pattern-based sequencer
    vcv-rack # powerful soft modular synth
    vital # serum-like digital synth
  ];
}
