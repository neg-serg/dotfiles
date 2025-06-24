{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = [
      pkgs.pywalfox-native
      pkgs.tridactyl-native 
    ];
  };
  home.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
    MOZ_DBUS_REMOTE = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };
}

# // user_pref("app.shield.optoutstudies.enabled", false); // Disable Mozilla experiments
# // user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr", false); // Disable Mozilla experiments
# // user_pref("gfx.color_management.enablev4", true); // May cause color rendering issues
# // user_pref("pdfjs.disabled", true); // Disables built-in PDF viewer
# user_pref("accessibility.typeaheadfind.flashBar", 0); // Disable flashing search bar animation
# user_pref("browser.bookmarks.addedImportButton", false); // Hide "Import Bookmarks" button
# user_pref("browser.bookmarks.restore_default_bookmarks", false); // Prevent restoring default bookmarks
# user_pref("browser.contentblocking.category", "standard"); // Standard tracking protection (balanced privacy/compatibility)
# user_pref("browser.download.dir", "~/dw"); // Default download directory (~/dw)
# user_pref("browser.newtabpage.activity-stream.telemetry", false); // Disable new tab telemetry
# user_pref("browser.ping-centre.telemetry", false); // Block background connections to Mozilla servers
# user_pref("browser.region.update.region", "US"); // Force US region for content/services
# user_pref("browser.search.region", "US"); // Force US region for search engines
# user_pref("distribution.searchplugins.defaultLocale", "en-US"); // Default locale for search plugins
# user_pref("extensions.webextensions.restrictedDomains", ""); // SECURITY RISK: Allows extensions access to internal pages (not recommended)
# user_pref("general.useragent.locale", "en-US"); // Set browser locale to en-US
# user_pref("general.warnOnAboutConfig", false); // Disable about:config warning
# user_pref("gfx.color_management.enabled", true); // Enable color calibration support
# user_pref("gfx.color_management.mode", 1); // Color management mode
# user_pref("gfx.webrender.all", true); // Enable WebRender GPU acceleration
# user_pref("layers.acceleration.force-enabled", true); // Force hardware acceleration
# user_pref("network.trr.confirmation_telemetry_enabled", false); // Disable DoH telemetry
# user_pref("permissions.default.desktop-notification", 2); // Block desktop notifications by default
# user_pref("privacy.resistFingerprinting.block_mozAddonManager", true); // Enhance fingerprinting protection
# user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // Enable userChrome.css customization
# user_pref("toolkit.telemetry.reportingpolicy.firstRun", false); // Disable first-run telemetry
# user_pref("xpinstall.signatures.required", false); // SECURITY RISK: Disables extension signature verification
