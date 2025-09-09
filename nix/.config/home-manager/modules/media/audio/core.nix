{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.core.enable {
  home.packages = with pkgs; [
    alsa-utils # aplay -l and friends
    coppwr # low level control for pipewire
    helvum # pipewire router
    open-music-kontrollers.patchmatrix # alternative patcher
    pw-volume # pipewire volume
    pwvucontrol # pavucontrol for pipewire
    qpwgraph # yet another pipewire router
  ];
}
