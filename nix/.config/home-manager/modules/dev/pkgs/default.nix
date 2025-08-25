{pkgs, ...}: {
  home.packages = with pkgs; [
    cloc # count lines of code
    deheader # remove unneeded includes for c, cpp
    # dprint # code formatting platform
    flawfinder # examine c, cpp code for security flaws
    mypy # optional static-typing for python
    nodejs_24 # for npm support
    # radicle-explorer # web frontend for radicle
    # radicle-node # radicle server
    scc # parallel cloc
    shfmt # shell formatting
    stylua # lua styler
    tokei # count your code, quickly
  ];
}
