{pkgs, ...}: {
  home.packages = with pkgs; [
    guitarix # virtual guitar amplifier for Linux running with JACK
    gxplugins-lv2 # set of extra lv2 plugins from the guitarix project
    noisetorch # virtual microphone to suppress the noise
    orca-c # esoteric programming language designed to quickly create procedural sequencers
    reaper # А вот в рипере!
    rnnoise # neural network noise reduction
    sunvox # fast and powerful modular synthesizer with pattern-based sequencer
    tenacity # audio editor
    vital # serum-like digital synth
  ];
}
