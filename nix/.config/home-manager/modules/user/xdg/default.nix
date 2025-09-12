{
  lib,
  config,
  pkgs,
  ...
}:
with rec {
  browserRec = import ../web/default-browser-lib.nix {inherit lib pkgs config;};
  defaultApplications = {
    terminal = {
      cmd = "${pkgs.kitty}/bin/kitty";
      desktop = "kitty";
    };
    browser = {
      cmd = browserRec.bin;
      # Historically we kept just the desktop ID without suffix here.
      # Derive it from the full desktop file name.
      desktop = lib.removeSuffix ".desktop" browserRec.desktop;
    };
    editor = {
      cmd = "${pkgs.neovim}/bin/nvim";
      desktop = "nvim";
    };
  };

  browser = browserRec.desktop;
  pdfreader = "org.pwmt.zathura.desktop";
  telegram = "org.telegram.desktop.desktop";
  torrent = "transmission.desktop";
  video = "mpv.desktop";
  image = "swayimg.desktop";
  editor = "${defaultApplications.editor.desktop}.desktop";

  my_associations = {
    "text/html*" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    "x-scheme-handler/ftp" = browser;
    "x-scheme-handler/about" = browser;
    "x-scheme-handler/unknown" = browser;
    "x-scheme-handler/chrome" = browser;
    "application/x-extension-htm" = browser;
    "application/x-extension-html" = browser;
    "application/x-extension-shtml" = browser;
    "application/xhtml+xml" = browser;
    "application/x-extension-xhtml" = browser;
    "application/x-extension-xht" = browser;

    "audio/*" = video;
    "video/*" = video;
    "image/*" = image;
    "application/pdf" = pdfreader;
    "application/postscript" = pdfreader;
    "application/epub+zip" = pdfreader;
    "x-scheme-handler/tg" = telegram;
    "x-scheme-handler/vkteams" = ["vkteamsdesktop.desktop"];
    "x-scheme-handler/spotify" = ["spotify.desktop"];
    "x-scheme-handler/discord" = ["vesktop.desktop"];
    "x-scheme-handler/magnet" = torrent;
    "x-scheme-handler/application/x-bittorrent" = torrent;

    "x-scheme-handler/nxm" = ["vortex-downloads-handler.desktop"];
    "x-scheme-handler/nxm-protocol" = ["vortex-downloads-handler.desktop"];

    "text/english" = editor;
    "text/plain" = editor;
    "text/x-makefile" = editor;
    "text/x-c++hdr" = editor;
    "text/x-c++src" = editor;
    "text/x-chdr" = editor;
    "text/x-csrc" = editor;
    "text/x-java" = editor;
    "text/x-moc" = editor;
    "text/x-pascal" = editor;
    "text/x-tcl" = editor;
    "text/x-tex" = editor;
    "application/x-shellscript" = editor;
    "application/json" = editor;
    "application/xml" = editor;
    "text/xml" = editor;
    "text/x-c" = editor;
    "text/x-c++" = editor;
  };

  associations_removed = {
    "application/vnd.ms-htmlhelp" = "wine-extension-chm.desktop";
    "image/gif" = ["wine-extension-gif.desktop"];
    "application/winhlp" = "wine-extension-hlp.desktop";
    "application/x-wine-extension-ini" = "wine-extension-ini.desktop";
    "application/x-wine-extension-msp" = "wine-extension-msp.desktop";
    "application/pdf" = ["wine-extension-pdf.desktop"];
    "application/rtf" = "wine-extension-rtf.desktop";
    "text/plain" = "wine-extension-txt.desktop";
    "application/x-mswinurl" = "wine-extension-url.desktop";
    "application/x-wine-extension-vbs" = "wine-extension-vbs.desktop";
    "application/x-mswrite" = "wine-extension-wri.desktop";
    "application/xml" = "wine-extension-xml.desktop";
    "text/html" = ["wine-extension-htm.desktop"];
    "image/jpeg" = ["wine-extension-jfif.desktop" "wine-extension-jpe.desktop"];
    "image/png" = ["wine-extension-png.desktop"];
  };
}; {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    handlr # xdg-open replacement with per-handler rules
    xdg-ninja # detect mislocated files in $HOME
  ]);
  # Aggregate XDG fixups to reduce activation noise and avoid per-file steps.
  # Prepare parent directories (un-symlink) and remove conflicting targets
  # for all declared xdg.{config,data,cache}File entries before linkGeneration.
  home.activation.xdgFixParents = lib.hm.dag.entryBefore ["linkGeneration"] (
    let
      cfgs = builtins.attrNames (config.xdg.configFile or {});
      datas = builtins.attrNames (config.xdg.dataFile or {});
      caches = builtins.attrNames (config.xdg.cacheFile or {});
      q = s: "\"" + s + "\"";
      join = xs: lib.concatStringsSep " " (map q xs);
    in ''
      set -eu
      config_home="$XDG_CONFIG_HOME"; [ -n "$config_home" ] || config_home="$HOME/.config"
      data_home="$XDG_DATA_HOME";   [ -n "$data_home" ]   || data_home="$HOME/.local/share"
      cache_home="$XDG_CACHE_HOME"; [ -n "$cache_home" ]  || cache_home="$HOME/.cache"

      for rel in ${join cfgs}; do
        tgt="$config_home/$rel"; parent="$(dirname "$tgt")"
        if [ -L "$parent" ]; then rm -f "$parent"; fi
        mkdir -p "$parent"
      done
      for rel in ${join datas}; do
        tgt="$data_home/$rel"; parent="$(dirname "$tgt")"
        if [ -L "$parent" ]; then rm -f "$parent"; fi
        mkdir -p "$parent"
      done
      for rel in ${join caches}; do
        tgt="$cache_home/$rel"; parent="$(dirname "$tgt")"
        if [ -L "$parent" ]; then rm -f "$parent"; fi
        mkdir -p "$parent"
      done
    ''
  );
  home.activation.xdgFixTargets = lib.hm.dag.entryBefore ["linkGeneration"] (
    let
      cfgs = builtins.attrNames (config.xdg.configFile or {});
      datas = builtins.attrNames (config.xdg.dataFile or {});
      caches = builtins.attrNames (config.xdg.cacheFile or {});
      q = s: "\"" + s + "\"";
      join = xs: lib.concatStringsSep " " (map q xs);
    in ''
      set -eu
      config_home="$XDG_CONFIG_HOME"; [ -n "$config_home" ] || config_home="$HOME/.config"
      data_home="$XDG_DATA_HOME";   [ -n "$data_home" ]   || data_home="$HOME/.local/share"
      cache_home="$XDG_CACHE_HOME"; [ -n "$cache_home" ]  || cache_home="$HOME/.cache"

      for rel in ${join cfgs}; do
        tgt="$config_home/$rel"
        if [ -L "$tgt" ]; then rm -f "$tgt"; fi
        if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
          if [ -d "$tgt" ]; then rm -rf "$tgt"; else rm -f "$tgt"; fi
        fi
      done
      for rel in ${join datas}; do
        tgt="$data_home/$rel"
        if [ -L "$tgt" ]; then rm -f "$tgt"; fi
        if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
          if [ -d "$tgt" ]; then rm -rf "$tgt"; else rm -f "$tgt"; fi
        fi
      done
      for rel in ${join caches}; do
        tgt="$cache_home/$rel"
        if [ -L "$tgt" ]; then rm -f "$tgt"; fi
        if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
          if [ -d "$tgt" ]; then rm -rf "$tgt"; else rm -f "$tgt"; fi
        fi
      done
    ''
  );
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/.local/desktop";
      documents = "${config.home.homeDirectory}/doc";
      download = "${config.home.homeDirectory}/dw";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pic";
      publicShare = "${config.home.homeDirectory}/1st_level/public";
      templates = "${config.home.homeDirectory}/1st_level/templates";
      videos = "${config.home.homeDirectory}/vid";
      extraConfig = {
        XDG_BIN_HOME = "${config.home.homeDirectory}/.local/bin";
        XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
        XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
        XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
        XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
      };
    };
    mime.enable = true;
    mimeApps = lib.mkMerge [
      {
        enable = true;
      }
      (lib.mkIf config.features.web.enable {
        associations.added = my_associations;
        defaultApplications = my_associations;
      })
      {
        associations.removed = associations_removed;
      }
    ];
  };
  # Consolidated minor pre-link tasks to minimize activation noise
  home.activation.prepareUserPaths = lib.hm.dag.entryBefore ["linkGeneration"] ''
    set -eu
    config_home="$XDG_CONFIG_HOME"; [ -n "$config_home" ] || config_home="$HOME/.config"
    state_home="$XDG_STATE_HOME";   [ -n "$state_home" ]   || state_home="$HOME/.local/state"
    bin_home="$HOME/.local/bin"

    # Ensure common runtime/config dirs exist
    mkdir -p "$config_home/mpv" \
             "$config_home/transmission-daemon" \
             "$state_home/zsh" \
             "$bin_home"

    # Ensure swayimg wrapper target is clean before link
    tgt="$bin_home/swayimg"
    if [ -e "$tgt" ] || [ -L "$tgt" ]; then rm -rf "$tgt"; fi

    # Ensure Maildir tree for gmail
    ensure_maildir() {
      base="$1"
      shift
      for box in "$@"; do
        mkdir -p "$base/$box/cur" "$base/$box/new" "$base/$box/tmp"
      done
    }
    ensure_maildir "$HOME/.local/mail/gmail" \
      "INBOX" \
      "[Gmail]/Sent Mail" \
      "[Gmail]/Drafts" \
      "[Gmail]/All Mail"
  '';
}
