{pkgs, ...}: {
  home.packages = with pkgs; [
    bespokesynth # nice modular synth
    dexed # nice yamaha dx7-like fm synth
    noisetorch # virtual microphone to suppress the noise
    ocenaudio # good audio editor
    reaper # А вот в рипере!
    renoise # modern tracker
    rnnoise # neural network noise reduction
    stochas # nice free sequencer
    vcv-rack # powerful soft modular synth
    vital # serum-like digital synth
  ];
}
