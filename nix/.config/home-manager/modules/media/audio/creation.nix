{pkgs, ...}: {
  home.packages = with pkgs; [
    guitarix # virtual guitar amplifier for Linux running with JACK
    gxplugins-lv2 # set of extra lv2 plugins from the guitarix project
    noisetorch # virtual microphone to suppress the noise
    orca-c # esoteric programming language designed to quickly create procedural sequencers
    reaper # А вот в рипере!
    rnnoise # neural network noise reduction
    sonic-pi # free live coding synth for everyone originally designed to support computing and music lessons within schools
    stochas # nice free sequencer
    sunvox # fast and powerful modular synthesizer with pattern-based sequencer
    surge-XT # great wavetable synth 
    tenacity # audio editor
    vcv-rack # powerful soft modular synth
    vital # serum-like digital synth
  ];
}
