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
  browser = import ./default-browser-lib.nix {inherit lib pkgs config yandexBrowser nyxt4;};
in {
  # Choose the default browser for system-wide handlers and $BROWSER
  options.features.web.default = mkOption {
    type = types.enum ["floorp" "firefox" "librewolf" "nyxt" "yandex"];
    default = "floorp";
    description = "Default browser used for XDG handlers, $BROWSER, and integrations.";
  };

  # Expose derived default browser under lib.neg for reuse
  config.lib.neg.web = mkIf cfg.enable {defaultBrowser = browser;};

  # Provide common env defaults (can be overridden elsewhere if needed)
  config.home.sessionVariables = mkIf cfg.enable {
    BROWSER = browser.bin;
    DEFAULT_BROWSER = browser.bin;
  };

  # Provide minimal sane defaults for common browser handlers
  config.xdg.mimeApps = mkIf cfg.enable {
    enable = true;
    defaultApplications = {
      "text/html" = browser.desktop;
      "x-scheme-handler/http" = browser.desktop;
      "x-scheme-handler/https" = browser.desktop;
      "x-scheme-handler/about" = browser.desktop;
      "x-scheme-handler/unknown" = browser.desktop;
    };
  };
}
