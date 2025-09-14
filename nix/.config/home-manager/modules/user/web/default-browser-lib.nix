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
in
  if (cfg.default or "floorp") == "yandex" && yandexBrowser != null
  then {
    name = "yandex";
    pkg = yandexBrowser.yandex-browser-stable;
    bin = "${yandexBrowser.yandex-browser-stable}/bin/yandex-browser-stable";
    desktop = "yandex-browser.desktop";
    newTabArg = "--new-tab";
  }
  else if (cfg.default or "floorp") == "firefox"
  then {
    name = "firefox";
    pkg = pkgs.firefox;
    bin = "${pkgs.firefox}/bin/firefox";
    desktop = "firefox.desktop";
    newTabArg = "-new-tab";
  }
  else if (cfg.default or "floorp") == "librewolf"
  then {
    name = "librewolf";
    pkg = pkgs.librewolf;
    bin = "${pkgs.librewolf}/bin/librewolf";
    desktop = "librewolf.desktop";
    newTabArg = "-new-tab";
  }
  else if (cfg.default or "floorp") == "nyxt"
  then {
    name = "nyxt";
    pkg =
      if nyxt4 != null
      then nyxt4
      else pkgs.nyxt;
    bin = "${(
      if nyxt4 != null
      then nyxt4
      else pkgs.nyxt
    )}/bin/nyxt";
    desktop = "nyxt.desktop";
    newTabArg = "";
  }
  else {
    name = "floorp";
    pkg = pkgs.floorp-bin;
    bin = "${pkgs.floorp-bin}/bin/floorp";
    desktop = "floorp.desktop";
    newTabArg = "-new-tab";
  }
