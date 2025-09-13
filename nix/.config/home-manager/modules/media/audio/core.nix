{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.core.enable (
  {
    home.packages = with pkgs; config.lib.neg.pkgsList [
      # utils
      alsa-utils coppwr pw-volume pwvucontrol
      # routers
      helvum qpwgraph open-music-kontrollers.patchmatrix
    ];
  }
)
