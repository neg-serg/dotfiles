{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.features.media.audio.core.enable (
  {
    home.packages = config.lib.neg.pkgsList [
      # utils
      pkgs.alsa-utils pkgs.coppwr pkgs.pw-volume pkgs.pwvucontrol
      # routers
      pkgs.helvum pkgs.qpwgraph pkgs.open-music-kontrollers.patchmatrix
    ];
  }
)
