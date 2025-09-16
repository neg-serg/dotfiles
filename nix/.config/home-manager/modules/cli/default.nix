{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  groups = with pkgs; rec {
    # Text/formatting/regex/CSV/TOML tools
    text = [
      choose # yet another cut/awk alternative
      enca # reencode files based on content
      grex # generate regexes from examples
      miller # awk/cut/join alternative for CSV/TSV/JSON
      par # paragraph reformatter (fmt++)
      sad # simpler sed alternative
      sd # intuitive sed alternative
      taplo # TOML toolkit (fmt, lsp, lint)
    ];

    # Filesystems, archives, hashing, mass rename, duplication
    fs = [
      convmv # convert filename encodings
      czkawka # find duplicates/similar files
      dcfldd # dd with progress/hash
      massren # massive rename utility
      ouch # archive extractor/creator
      patool # universal archive unpacker (python)
      ranger # file manager (needed for termfilechooser)
      rhash # hash sums calculator
    ];

    # Networking, cloud CLIs, URL tooling
    net = [
      kubectx # fast switch Kubernetes contexts
      scaleway-cli # Scaleway cloud CLI
      speedtest-cli # internet speed test
      urlscan # extract URLs from text
      urlwatch # watch pages for changes
      zfxtop # Cloudflare/ZFX top-like monitor
    ];

    # System info and observability
    obs = [
      below # BPF-based system history
      lnav # log file navigator
      viddy # modern watch with history
    ];
    sys = [
      cpufetch # CPU info fetch
      ramfetch # RAM info fetch
      ydotool # input emulation tool (Wayland/X11-agnostic)
    ];

    # Dev helpers, diffs, automation, navigation
    dev = [
      babashka # native Clojure scripting runtime
      diffoscope # deep diff for many formats
      diff-so-fancy # human-friendly git diff pager
      entr # run commands on file change
      expect # automate interactive TTY programs
      fasd # MRU-based CLI autojump/completion
      mergiraf # AST-aware git merge driver
      zoxide # smarter cd with ranking
    ];
  };
in {
  options.features.cli = {
    text = config.lib.neg.mkBool "enable text/formatting/CSV/TOML tools" true;
    fs = config.lib.neg.mkBool "enable filesystem/archive/hash/mass-rename tools" true;
    net = config.lib.neg.mkBool "enable network/cloud/URL tools" true;
    obs = config.lib.neg.mkBool "enable observability/log tools" true;
    sys = config.lib.neg.mkBool "enable system fetch utilities" true;
    dev = config.lib.neg.mkBool "enable dev helpers/diffs/automation" true;
    icedteaWeb.enable = config.lib.neg.mkBool "enable IcedTea Web (netx) and user config" false;
  };
  imports = [
    ./core-tools.nix # fd, ripgrep, direnv, shell helpers
    ./bat.nix # better cat
    ./broot.nix # nested fuzzy finding
    ./btop.nix
    ./fastfetch.nix
    ./nushell.nix
    ./config-links.nix # dircolors, f-sy-h, zsh, inputrc
    ./amfora.nix
    ./icedtea-web.nix
    ./dosbox.nix
    ./fzf.nix
    ./tmux.nix
    ./tig.nix
    ./yazi.nix
  ];
  config = {
    programs = {
      hwatch = {enable = true;}; # better watch with history
      kubecolor = {enable = true;}; # kubectl colorizer
      nix-search-tv = {enable = true;}; # fast search for nix packages
      numbat = {enable = true;}; # fancy scientific calculator
      television = {enable = true;}; # yet another fuzzy finder
      tray-tui = {enable = true;}; # system tray in your terminal
      visidata = {enable = true;}; # interactive multitool for tabular data
    };
    home.packages =
      config.lib.neg.pkgsList (config.lib.neg.mkEnabledList config.features.cli groups)
      ++ [pkgs.tealdeer]; # tldr replacement written in Rust
  };
}
