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
  browsers = import ./browsers-table.nix { inherit lib pkgs yandexBrowser nyxt4; };
  browser = let key = cfg.default or "floorp"; in lib.attrByPath [key] browsers browsers.floorp;
in {
  # Choose the default browser for system-wide handlers and $BROWSER
  options.features.web.default = mkOption {
    type = types.enum ["floorp" "firefox" "librewolf" "nyxt" "yandex"];
    default = "floorp";
    description = "Default browser used for XDG handlers, $BROWSER, and integrations.";
  };

  # Expose derived default browser under lib.neg for reuse
  config.lib.neg.web = mkIf cfg.enable {
    defaultBrowser = browser;
    inherit browsers;
  };

  # Provide common env defaults (can be overridden elsewhere if needed)
  config.home.sessionVariables = mkIf cfg.enable (
    let db = browser; in {
      BROWSER = db.bin or "${pkgs.xdg-utils}/bin/xdg-open";
      DEFAULT_BROWSER = db.bin or "${pkgs.xdg-utils}/bin/xdg-open";
    }
  );

  # Provide minimal sane defaults for common browser handlers
  config.xdg.mimeApps = mkIf cfg.enable (
    let db = browser; in {
    enable = true;
    defaultApplications = {
      "text/html" = db.desktop or "floorp.desktop";
      "x-scheme-handler/http" = db.desktop or "floorp.desktop";
      "x-scheme-handler/https" = db.desktop or "floorp.desktop";
      "x-scheme-handler/about" = db.desktop or "floorp.desktop";
      "x-scheme-handler/unknown" = db.desktop or "floorp.desktop";
    };
  });
}
