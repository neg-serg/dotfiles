{pkgs, ...}: {
  home.packages = with pkgs; [
    nyxt # yet another fancy browser
  ];
}
