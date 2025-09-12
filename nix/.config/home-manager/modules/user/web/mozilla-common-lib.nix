{
  lib,
  pkgs,
  config,
  fa ? null,
  ...
}:
with lib; let
  dlDir = "${config.home.homeDirectory}/dw";
  fa' =
    if fa != null
    then fa
    else pkgs.nur.repos.rycee.firefox-addons;
  addons = config.lib.neg.browserAddons fa';

  nativeMessagingHosts = [
    pkgs.pywalfox-native
    pkgs.tridactyl-native
  ];

  settings = {
    "browser.region.update.region" = "US";
    "browser.search.region" = "US";
    "intl.locale.requested" = "en-US";

    "browser.download.dir" = dlDir;
    "browser.download.useDownloadDir" = true;
    "general.warnOnAboutConfig" = false;
    "accessibility.typeaheadfind.flashBar" = 0;
    "browser.bookmarks.addedImportButton" = false;
    "browser.bookmarks.restore_default_bookmarks" = false;
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

    "browser.contentblocking.category" = "standard";

    "permissions.default.desktop-notification" = 2;

    "privacy.resistFingerprinting.block_mozAddonManager" = true;

    "pdfjs.disabled" = true;
    "pdfjs.enableScripting" = false;
    "pdfjs.enableXFA" = false;

    "gfx.color_management.enabled" = true;
    "gfx.color_management.enablev4" = false;

    "dom.ipc.processCount" = 8;
    "fission.autostart" = true;
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

    "media.ffmpeg.vaapi.enabled" = true;
    "media.hardware-video-decoding.enabled" = true;

    "media.autoplay.default" = 1;
    "media.autoplay.blocking_policy" = 2;
    "media.autoplay.block-webaudio" = true;
    "media.block-autoplay-until-in-foreground" = true;

    "browser.startup.preXulSkeletonUI" = false;
  };

  extraConfig = ''
    // Optional / disabled prefs (enable only if you really want them)
    // user_pref("extensions.webextensions.restrictedDomains", "");
    // user_pref("xpinstall.signatures.required", false);
    // user_pref("network.trr.mode", 3);
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
    :root { --urlbar-min-height: 36px !important; }
    #urlbar-input {
      font-size: 17px !important;
      font-weight: 500 !important;
    }

    .urlbarView-row .urlbarView-title,
    .urlbarView-row .urlbarView-url {
      font-size: 14px !important;
      font-weight: 400 !important;
    }
  '';

  policies = {
    ExtensionSettings = {
      "hide-scrollbars@qashto" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/hide-scrollbars/latest.xpi";
      };

      "{4a311e5c-1ccc-49b7-9c23-3e2b47b6c6d5}" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/%D1%81%D0%BA%D0%B0%D1%87%D0%B0%D1%82%D1%8C-%D0%BC%D1%83%D0%B7%D1%8B%D0%BA%D1%83-%D1%81-%D0%B2%D0%BA-vkd/latest.xpi";
      };

      "kellyc-show-youtube-dislikes@nradiowave" = {
        installation_mode = "force_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/kellyc-show-youtube-dislikes/latest.xpi";
      };

      # Explicitly block Tampermonkey userscript manager
      "firefox@tampermonkey.net" = {
        installation_mode = "blocked";
      };
    };

    Extensions = {
      Install = true;
      Updates = true;
    };
  };
in {
  inherit nativeMessagingHosts settings extraConfig userChrome policies addons;
  profileId = "bqtlgdxw.default";
}
