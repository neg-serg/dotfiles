{
  lib,
  pkgs,
  config,
  yandexBrowser ? null,
  nyxt4 ? null,
  ...
}:
with lib; let
  cfg = config.features.web;

  # Map the selected default browser to common fields used elsewhere
  browser =
    if (cfg.default or "floorp") == "yandex" && yandexBrowser != null then {
      name = "yandex";
      pkg = yandexBrowser.yandex-browser-stable;
      bin = "${yandexBrowser.yandex-browser-stable}/bin/yandex-browser-stable";
      desktop = "yandex-browser.desktop";
      newTabArg = "--new-tab";
    } else if (cfg.default or "floorp") == "firefox" then {
      name = "firefox";
      pkg = pkgs.firefox;
      bin = "${pkgs.firefox}/bin/firefox";
      desktop = "firefox.desktop";
      newTabArg = "-new-tab";
    } else if (cfg.default or "floorp") == "librewolf" then {
      name = "librewolf";
      pkg = pkgs.librewolf;
      bin = "${pkgs.librewolf}/bin/librewolf";
      desktop = "librewolf.desktop";
      newTabArg = "-new-tab";
    } else if (cfg.default or "floorp") == "nyxt" then {
      name = "nyxt";
      pkg = if nyxt4 != null then nyxt4 else pkgs.nyxt;
      bin = "${(if nyxt4 != null then nyxt4 else pkgs.nyxt)}/bin/nyxt";
      desktop = "nyxt.desktop";
      newTabArg = "";
    } else {
      name = "floorp";
      pkg = pkgs.floorp;
      bin = "${pkgs.floorp}/bin/floorp";
      desktop = "floorp.desktop";
      newTabArg = "-new-tab";
    };
in {
  # Choose the default browser for system-wide handlers and $BROWSER
  options.features.web.default = mkOption {
    type = types.enum ["floorp" "firefox" "librewolf" "nyxt" "yandex"];
    default = "floorp";
    description = "Default browser used for XDG handlers, $BROWSER, and integrations.";
  };

  config = mkIf cfg.enable {
    # Expose derived default browser under lib.neg for reuse
    config.lib.neg.web = {
      defaultBrowser = browser;
    };

    # Provide common env defaults (can be overridden elsewhere if needed)
    home.sessionVariables = {
      BROWSER = browser.bin;
      DEFAULT_BROWSER = browser.bin;
    };

    # Provide minimal sane defaults for common browser handlers
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = browser.desktop;
        "x-scheme-handler/http" = browser.desktop;
        "x-scheme-handler/https" = browser.desktop;
        "x-scheme-handler/about" = browser.desktop;
        "x-scheme-handler/unknown" = browser.desktop;
      };
    };
  };
}
