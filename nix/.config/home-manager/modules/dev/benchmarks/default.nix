{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    memtester # memory test
    rewrk # http benchmark
    stress-ng # stress testing
    vrrtest # freesync/gsync working test
    wrk2 # yet another http benchmark
  ];
}
