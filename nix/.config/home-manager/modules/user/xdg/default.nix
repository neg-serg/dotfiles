{
  lib,
  config,
  pkgs,
  ...
}:
with rec {
  db = config.lib.neg.web.defaultBrowser or {};
  browserRec = {
    bin = db.bin or "${pkgs.xdg-utils}/bin/xdg-open";
    desktop = db.desktop or "floorp.desktop";
  };
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

  # Minimal associations to keep noise low; handlr covers the rest
  my_associations = {
    # Browsing
    "text/html" = browser;
    "application/xhtml+xml" = browser;
    "x-scheme-handler/http" = browser;
    "x-scheme-handler/https" = browser;
    # Media
    "audio/*" = video;
    "video/*" = video;
    "image/*" = image;
    "application/pdf" = pdfreader;
    # Misc handlers
    "x-scheme-handler/magnet" = torrent;
    "x-scheme-handler/tg" = telegram;
    # Editing
    "text/plain" = editor;
    "application/json" = editor;
    "application/x-shellscript" = editor;
  };
}; {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    handlr # xdg-open replacement with per-handler rules
    xdg-ninja # detect mislocated files in $HOME
  ];
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
        case "$rel" in
          transmission-daemon/*)
            # Preserve user symlinked transmission config dir (resume/history)
            : ;;
          *)
            if [ -L "$parent" ]; then rm -f "$parent"; fi
            mkdir -p "$parent" ;;
        esac
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
    ];
  };
  # Replace ad-hoc ensure/clean steps with lib.neg helpers
  # Ensure common runtime/config dirs exist as real directories
  home.activation.ensureCommonDirs =
    config.lib.neg.mkEnsureRealDirsMany [
      "${config.xdg.configHome}/mpv"
      "${config.xdg.stateHome}/zsh"
      "${config.home.homeDirectory}/.local/bin"
    ];

  # Preserve user symlinks for Transmission config (history/resume). Do not
  # force the directory to be a real dir here — only clean up if it's a broken
  # symlink to avoid nuking external setups.
  home.activation.keepTransmissionConfigSymlink =
    config.lib.neg.mkRemoveIfBrokenSymlink "${config.xdg.configHome}/transmission-daemon";

  # Ensure swayimg wrapper target is absent before linking the wrapper
  home.activation.cleanSwayimgWrapper =
    config.lib.neg.mkEnsureAbsent "${config.home.homeDirectory}/.local/bin/swayimg";

  # Ensure Gmail Maildir tree exists (INBOX, Sent, Drafts, All Mail)
  home.activation.ensureGmailMaildirs =
    config.lib.neg.mkEnsureMaildirs "${config.home.homeDirectory}/.local/mail/gmail" [
      "INBOX"
      "[Gmail]/Sent Mail"
      "[Gmail]/Drafts"
      "[Gmail]/All Mail"
    ];
}
