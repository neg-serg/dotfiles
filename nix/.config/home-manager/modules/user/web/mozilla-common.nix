{
  lib,
  pkgs,
  config,
  fa ? null,
  ...
}:
with lib; let
  dlDir = "${config.home.homeDirectory}/dw";
  fa' = if fa != null then fa else pkgs.nur.repos.rycee.firefox-addons; # requires NUR
  addons = config.lib.neg.browserAddons fa';

  nativeMessagingHosts = [
    pkgs.pywalfox-native # pywalfox native host for theming
    pkgs.tridactyl-native # Tridactyl native host
  ];

  settings = {
    # Region / locale
    "browser.region.update.region" = "US";
    "browser.search.region" = "US";
    "intl.locale.requested" = "en-US";

    # Downloads / UX
    "browser.download.dir" = dlDir;
    "browser.download.useDownloadDir" = true;
    "general.warnOnAboutConfig" = false;
    "accessibility.typeaheadfind.flashBar" = 0;
    "browser.bookmarks.addedImportButton" = false;
    "browser.bookmarks.restore_default_bookmarks" = false;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    # Content blocking
    "browser.contentblocking.category" = "standard";

    # Notifications (0 allow, 1 ask, 2 block)
    "permissions.default.desktop-notification" = 2;

    # Fingerprinting
    "privacy.resistFingerprinting.block_mozAddonManager" = true;

    # PDF viewer
    "pdfjs.disabled" = true;
    "pdfjs.enableScripting" = false;
    "pdfjs.enableXFA" = false;

    # Color management
    "gfx.color_management.enabled" = true;
    "gfx.color_management.enablev4" = false;

    # FastFox-like (safe subset)
    "dom.ipc.processCount" = 8; # more content processes
    "fission.autostart" = true; # site isolation
    "network.http.max-connections" = 1800;
    "network.http.max-persistent-connections-per-server" = 10;
    "network.http.max-urgent-start-excessive-connections-per-host" = 6;
    "network.dnsCacheEntries" = 10000;
    "network.dnsCacheExpirationGracePeriod" = 240;
    "network.ssl_tokens_cache_capacity" = 32768;
    "network.speculative-connection.enabled" = true;
    "browser.tabs.unloadOnLowMemory" = true;
    "browser.sessionstore.restore_tabs_lazily" = true;
    "gfx.webrender.all" = true;
    "gfx.webrender.precache-shaders" = true;

    # HW video decoding (Wayland/VA-API)
    "media.ffmpeg.vaapi.enabled" = true;
    "media.hardware-video-decoding.enabled" = true;

    # Disable autoplay
    "media.autoplay.default" = 1; # block audible
    "media.autoplay.blocking_policy" = 2;
    "media.autoplay.block-webaudio" = true;
    "media.block-autoplay-until-in-foreground" = true;

    # Minor QoL
    "browser.startup.preXulSkeletonUI" = false;
  };

  extraConfig = ''
    // Optional / disabled prefs (enable only if you really want them)
    // user_pref("extensions.webextensions.restrictedDomains", ""); // SECURITY RISK: grants extensions access to internal pages
    // user_pref("xpinstall.signatures.required", false); // SECURITY RISK: disables extension signature check
    // DoH template (fill if you want DoH)
    // user_pref("network.trr.mode", 3); // 2 = DoH only, 3 = DoH with fallback
    // user_pref("network.trr.uri", "https://dns.example/dns-query");
    // user_pref("network.trr.bootstrapAddress", "9.9.9.9");
  '';

  userChrome = ''
    /* Hide buttons you don't use */
    #nav-bar #back-button,
    #nav-bar #forward-button,
    #nav-bar #stop-reload-button,
    #nav-bar #home-button { display: none !important; }

    /* Bigger, bolder URL bar text */
    :root { --urlbar-min-height: 36px !important; } /* increase bar height */
    #urlbar-input {
      font-size: 17px !important;   /* adjust size */
      font-weight: 500 !important;  /* 600–700 = semi-bold/bold */
    }

    /* Optional: make suggestions list text match */
    .urlbarView-row .urlbarView-title,
    .urlbarView-row .urlbarView-url {
      font-size: 14px !important;
      font-weight: 400 !important;
    }
  '';

  policies = {
    ExtensionSettings = {
      # Hide Scrollbars
      "hide-scrollbars@qashto" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/hide-scrollbars/latest.xpi";
      };

      # Free music downloader for VK (slug/ID may change on AMO)
      "{4a311e5c-1ccc-49b7-9c23-3e2b47b6c6d5}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C-%D0%BC%D1%83%D0%B7%D1%8B%D0%BA%D1%83-%D1%81-%D0%B2%D0%BA-vkd/latest.xpi";
      };

      # KellyC Show YouTube Dislikes (may be unavailable on AMO at times)
      "kellyc-show-youtube-dislikes@nradiowave" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/kellyc-show-youtube-dislikes/latest.xpi";
      };
    };

    Extensions = {
      Install = true;
      Updates = true;
    };
  };
in {
  # Expose a reusable record with common Mozilla-family config bits
  config.lib.neg.web.mozillaCommon = {
    inherit nativeMessagingHosts settings extraConfig userChrome policies addons;
    profileId = "bqtlgdxw.default";
  };
}

