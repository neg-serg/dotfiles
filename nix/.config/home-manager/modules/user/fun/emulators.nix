{pkgs, ...}: {
  home.packages = with pkgs; [
    pcem # emulator for ibm pc and clones
    pcsx2 # ps2 emulator
    retroarchFull # multiplatform emulator frontend
  ];
}
