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
    ./yazi.nix
  ];
  programs.atuin = {
    enable = true;
    flags = [ "--disable-up-arrow" ];
    settings = {
      update_check = false;
      style = "compact";
      invert = true;
      inline_height = 15;
      show_help = false;
      show_tabs = false;
      enter_accept = true;
      prefers_reduced_motion = true;
      keys.scroll_exits = false;
    };
  };
  home.packages = with pkgs; [
    babashka # native clojure for scripts
    below # interactive tool to view and record historical system data
    choose # yet another cut/awk alternative
    convmv # convert filename encodings
    cpufetch # fetch for cpu
    czkawka # find duplicate pictures and more
    dcfldd # better dd with progress bar and inline hash verification
    diff-so-fancy # human-readable diff
    diffoscope # diff for various format
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
    numbat # fancy scientific calculator
    ouch # cli archive extractor
    par # better fmt
    patool # python archive unpack
    ramfetch # fetch for ram
    ranger # need for termfilechooser
    rhash # compute hashsums
    sad # more simple sed alternative
    sd # bettter sed
    speedtest-cli # test network
    taplo # fancy toml toolkit
    tealdeer # short man, tldr replacement written in rust
    urlscan # extract urls from text
    urlwatch # watch for urls
    viddy # modern watch command
    zfxtop # fancy top in commandline
    zoxide # better fasd for some
  ];
}
