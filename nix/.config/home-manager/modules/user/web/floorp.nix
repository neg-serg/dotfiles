{ config, pkgs, ... }:
let
  dlDir = "${config.home.homeDirectory}/dw";
in
{
  programs.floorp = {
    enable = true;

    nativeMessagingHosts = [
      pkgs.pywalfox-native
      pkgs.tridactyl-native
    ];

    profiles."bqtlgdxw.default" = {
      isDefault = true;

      # about:config prefs
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
        "pdfjs.disabled" = false;
        "pdfjs.enableScripting" = false;
        "pdfjs.enableXFA" = false;

        # Color management
        "gfx.color_management.enabled" = true;
        "gfx.color_management.enablev4" = false;

        # FastFox-like (safe subset)
        "dom.ipc.processCount" = 8;                                # more content processes
        "fission.autostart" = true;                                # site isolation
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
        "media.autoplay.default" = 1;                               # block audible
        "media.autoplay.blocking_policy" = 2;
        "media.autoplay.block-webaudio" = true;
        "media.block-autoplay-until-in-foreground" = true;

        # Minor QoL
        "browser.startup.preXulSkeletonUI" = false;
      };

      # Optional toggles kept from your config
      extraConfig = ''
        // Optional / disabled prefs (enable only if you really want them)

        // SECURITY RISK: grants extensions access to internal pages
        // user_pref("extensions.webextensions.restrictedDomains", "");

        // SECURITY RISK: disables extension signature check
        // user_pref("xpinstall.signatures.required", false);

        // Fully disable built-in PDF viewer (not recommended)
        // user_pref("pdfjs.disabled", true);

        // DoH template (fill if you want DoH)
        // user_pref("network.trr.mode", 3); // 2 = DoH only, 3 = DoH with fallback
        // user_pref("network.trr.uri", "https://dns.example/dns-query");
        // user_pref("network.trr.bootstrapAddress", "9.9.9.9");

        // Forcing GPU acceleration may cause artifacts; usually unnecessary
        // user_pref("gfx.webrender.all", true);
        // user_pref("layers.acceleration.force-enabled", true);
      '';

      # Hide back/forward/reload/home buttons
      userChrome = ''
        #nav-bar #back-button,
        #nav-bar #forward-button,
        #nav-bar #stop-reload-button,
        #nav-bar #home-button { display: none !important; }
      '';
    };
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.floorp}/bin/floorp";
    MOZ_DBUS_REMOTE = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "floorp.desktop";
      "x-scheme-handler/http" = "floorp.desktop";
      "x-scheme-handler/https" = "floorp.desktop";
      "x-scheme-handler/about" = "floorp.desktop";
      "x-scheme-handler/unknown" = "floorp.desktop";
    };
  };
}
