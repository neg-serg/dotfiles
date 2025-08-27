{ config, pkgs, ... }:
let
  dlDir = "${config.home.homeDirectory}/dw"; # Firefox prefers an absolute path for the download directory.
in
{
  programs.firefox = {
    enable = true;
    # Native messaging hosts you provided
    nativeMessagingHosts = [
      pkgs.pywalfox-native
      pkgs.tridactyl-native
    ];

    # Profile with sane defaults and optional extras
    profiles.main = {
      isDefault = true;
      settings = {
        # --- Telemetry / Experiments ---
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "app.shield.optoutstudies.enabled" = false;

        # --- Region / Locale ---
        "browser.region.update.region" = "US";
        "browser.search.region" = "US";
        "distribution.searchplugins.defaultLocale" = "en-US";
        "intl.locale.requested" = "en-US";

        # --- Downloads / UX ---
        "browser.download.dir" = dlDir;
        "browser.download.useDownloadDir" = true;
        "general.warnOnAboutConfig" = false;
        "accessibility.typeaheadfind.flashBar" = 0;
        "browser.bookmarks.addedImportButton" = false;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # --- Content Blocking ---
        "browser.contentblocking.category" = "standard";

        # --- Notifications ---
        # 0 = allow, 1 = ask, 2 = block
        "permissions.default.desktop-notification" = 2;

        # --- Fingerprinting protection ---
        "privacy.resistFingerprinting.block_mozAddonManager" = true;

        # --- PDF Viewer (keep enabled, but disable scripting) ---
        "pdfjs.disabled" = false;
        "pdfjs.enableScripting" = false;
        "pdfjs.enableXFA" = false;

        # --- Color Management (enabled, but avoid v4 profiles) ---
        "gfx.color_management.enabled" = true;
        "gfx.color_management.enablev4" = false;
      };

      extraConfig = ''
        // ==================================
        // Optional / disabled preferences
        // ==================================

        // SECURITY RISK: grants extensions access to internal pages (AMO, accounts, etc.)
        // user_pref("extensions.webextensions.restrictedDomains", "");

        // SECURITY RISK: disables extension signature check
        // user_pref("xpinstall.signatures.required", false);

        // Disable built-in PDF viewer completely (not recommended)
        // user_pref("pdfjs.disabled", true);

        // DoH telemetry only
        // user_pref("network.trr.confirmation_telemetry_enabled", false);

        // Color management v4 profiles (can cause issues)
        // user_pref("gfx.color_management.enablev4", true);
        // user_pref("gfx.color_management.mode", 1);

        // Force-enable GPU acceleration (may cause artifacts)
        // user_pref("gfx.webrender.all", true);
        // user_pref("layers.acceleration.force-enabled", true);

        // Old locale pref (deprecated)
        // user_pref("general.useragent.locale", "en-US");

        // ==================================
        // Template for DoH
        // ==================================
        // Modes: 2 = DoH only, 3 = DoH with fallback
        // user_pref("network.trr.mode", 3);
        // user_pref("network.trr.uri", "https://dns.example/dns-query");
        // user_pref("network.trr.bootstrapAddress", "9.9.9.9");
      '';
    };
  };

  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
    MOZ_DBUS_REMOTE = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };

  xdg.mimeApps = {
    enable = true;  # ensure defaults are applied
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };

  # Optional: ship userChrome.css / userContent.css
  # xdg.configFile."firefox/chrome/userChrome.css".source = ./userChrome.css;
  # xdg.configFile."firefox/chrome/userContent.css".source = ./userContent.css;
}
