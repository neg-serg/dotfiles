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
      };

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
