{
  lib,
  pkgs,
  yandexBrowser ? null,
  nyxt4 ? null,
  ...
}:
let
  nyxtPkg = if nyxt4 != null then nyxt4 else pkgs.nyxt;
  floorpPkg = pkgs.floorp-bin;
in {
  firefox = {
    name = "firefox";
    pkg = pkgs.firefox;
    bin = "${pkgs.firefox}/bin/firefox";
    desktop = "firefox.desktop";
    newTabArg = "-new-tab";
  };
  librewolf = {
    name = "librewolf";
    pkg = pkgs.librewolf;
    bin = "${pkgs.librewolf}/bin/librewolf";
    desktop = "librewolf.desktop";
    newTabArg = "-new-tab";
  };
  nyxt = {
    name = "nyxt";
    pkg = nyxtPkg;
    bin = "${nyxtPkg}/bin/nyxt";
    desktop = "nyxt.desktop";
    newTabArg = "";
  };
  floorp = {
    name = "floorp";
    pkg = floorpPkg;
    bin = "${floorpPkg}/bin/floorp";
    desktop = "floorp.desktop";
    newTabArg = "-new-tab";
  };
} // (lib.optionalAttrs (yandexBrowser != null) {
  yandex = {
    name = "yandex";
    pkg = yandexBrowser.yandex-browser-stable;
    bin = "${yandexBrowser.yandex-browser-stable}/bin/yandex-browser-stable";
    desktop = "yandex-browser.desktop";
    newTabArg = "--new-tab";
  };
})

