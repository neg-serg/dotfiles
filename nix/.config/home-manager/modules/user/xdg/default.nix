{ 
  lib,
  config,
  pkgs,
  ...
}:
with rec {
  db = config.lib.neg.web.defaultBrowser or {};
  browserRec = {
    bin = db.bin or "${lib.getExe' pkgs.xdg-utils "xdg-open"}";
    desktop = db.desktop or "floorp.desktop";
  };
  defaultApplications = {
    terminal = {
      cmd = "${lib.getExe' pkgs.kitty "kitty"}";
      desktop = "kitty";
    };
    browser = {
      cmd = browserRec.bin;
      # Historically we kept just the desktop ID without suffix here.
      # Derive it from the full desktop file name.
      desktop = lib.removeSuffix ".desktop" browserRec.desktop;
    };
    editor = {
      cmd = "${lib.getExe' pkgs.neovim "nvim"}";
      desktop = "nvim";
    };
  };

  browser = browserRec.desktop;
  pdfreader = "org.pwmt.zathura.desktop";
  telegram = "org.telegram.desktop.desktop";
  # Transmission 4 desktop ID (explicit to avoid legacy alias)
  torrent = "org.transmissionbt.Transmission.desktop";
  video = "mpv.desktop";
  image = "swayimg.desktop";
  editor = "${defaultApplications.editor.desktop}.desktop";

  # Minimal associations to keep noise low; handlr covers the rest
  my_associations = (
    {
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
      "x-scheme-handler/tg" = telegram;
      # Editing
      "text/plain" = editor;
      "application/json" = editor;
      "application/x-shellscript" = editor;
    }
    // lib.optionalAttrs config.features.torrent.enable {
      "x-scheme-handler/magnet" = torrent;
    }
  );
}; let
  cfgNames = builtins.attrNames (config.xdg.configFile or {});
  dataNames = builtins.attrNames (config.xdg.dataFile or {});
  cacheNames = builtins.attrNames (config.xdg.cacheFile or {});
in {
  home.packages = config.lib.neg.pkgsList [
    pkgs.handlr # xdg-open replacement with per-handler rules
    pkgs.xdg-ninja # detect mislocated files in $HOME
  ];
  # Aggregate XDG fixups via lib.neg helpers for readability and reuse.
  home.activation.xdgFixParents = config.lib.neg.mkXdgFixParents {
    configs = cfgNames;
    datas = dataNames;
    caches = cacheNames;
  };
  home.activation.xdgFixTargets = config.lib.neg.mkXdgFixTargets {
    configs = cfgNames;
    datas = dataNames;
    caches = cacheNames;
  };
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

  # Ensure Gmail Maildir tree exists (INBOX, Sent, Drafts, All Mail)
  home.activation.ensureGmailMaildirs =
    config.lib.neg.mkEnsureMaildirs "${config.home.homeDirectory}/.local/mail/gmail" [
      "INBOX"
      "[Gmail]/Sent Mail"
      "[Gmail]/Drafts"
      "[Gmail]/All Mail"
    ];
}
