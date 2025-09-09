{pkgs, ...}: {
  home.packages = with pkgs; [
    almonds # TUI fractal viewer
    bucklespring # for keyboard sounds
    cool-retro-term # a retro terminal emulator
    dotacat # yet another color version of cat
    figlet # ascii art
    fortune # fortune cookie
    free42 # A software clone of HP-42S Calculator
    neo-cowsay # say something
    neo # yet another digital rain
    pkgs.neg.cxxmatrix # colorful matrix rain (C++ impl)
    nms # No More Secrets, a recreation of the live decryption effect from the famous hacker movie "Sneakers"
    solfege # ear training program
    taoup # The Tao of Unix Programming
    toilet # text banners
    xephem # astronomy app
    xlife # cellular automata
  ];
}
