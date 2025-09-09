{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.dev.enable {
    home.packages = with pkgs; [
      memtester # memory test
      rewrk # HTTP benchmark
      stress-ng # stress testing
      vrrtest # FreeSync/G-Sync test
      wrk2 # HTTP benchmark
    ];
  }
