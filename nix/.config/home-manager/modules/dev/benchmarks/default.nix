{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;
  home.packages = with pkgs; [
    memtester # memory test
    stress-ng # stress testing
    vrrtest # freesync/gsync working test
  ];
}
