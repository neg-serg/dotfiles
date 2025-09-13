{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.core.enable (
  let
    groups = with pkgs; {
      utils = [
        alsa-utils # aplay -l and friends
        coppwr # low level control for pipewire
        pw-volume # pipewire volume
        pwvucontrol # pavucontrol for pipewire
      ];
      routers = [
        helvum # pipewire router
        qpwgraph # yet another pipewire router
        open-music-kontrollers.patchmatrix # alternative patcher
      ];
    };
    flags = builtins.listToAttrs (map (n: {
      name = n;
      value = true;
    }) (builtins.attrNames groups));
  in {
    home.packages = config.lib.neg.pkgsList (config.lib.neg.mkEnabledList flags groups);
  }
)
