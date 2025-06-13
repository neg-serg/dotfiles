{
  pkgs,
  ...
}: {
  imports = [
    ./bat.nix # better cat
    ./broot.nix # nested fuzzy finding
    ./btop.nix
    ./fastfetch.nix
    ./fd.nix # better find
    ./fzf.nix
    ./ripgrep.nix
    ./shell.nix # shells which not in nixOs and their completions
    ./starship.nix # universal command prompt
    ./yazi.nix
  ];
  home.packages = with pkgs; [
    babashka # native clojure for scripts
    choose # yet another cut/awk alternative
    convmv # convert filename encodings
    czkawka # find duplicate pictures and more
    dcfldd # better dd with progress bar and inline hash verification
    diffoscope # diff for various format
    diff-so-fancy # human-readable diff
    enca # autoreencode
    entr # run commands when files change
    expect # do tty stuff noninteractively
    fasd # my favorite mru autocompletion
    frawk # small text processing language
    grex # tool to generate regexes
    lnav # logfile navigator
    massren # massive rename
    mergiraf # ast-aware git merge driver
    miller # awk/cut/join alternative
    par # better fmt
    patool # python archive unpack
    ranger # need for termfilechooser
    rhash # compute hashsums
    sad # more simple sed alternative
    sd # bettter sed
    speedtest-cli # test network
    tealdeer # short man, tldr replacement written in rust
    urlscan # extract urls from text
    urlwatch # watch for urls
    viddy # modern watch command
    zoxide # better fasd for some
  ];
}
