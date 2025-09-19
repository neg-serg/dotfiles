{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.dev.enable {
    home.packages = config.lib.neg.pkgsList [
      pkgs.memtester # memory test
      pkgs.rewrk # HTTP benchmark
      pkgs.stress-ng # stress testing
      pkgs.vrrtest # FreeSync/G-Sync test
      pkgs.wrk2 # HTTP benchmark
    ];
  }
