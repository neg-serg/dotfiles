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
  key = cfg.default or "floorp";
  browsers = import ./browsers-table.nix { inherit lib pkgs yandexBrowser nyxt4; };
in
  lib.attrByPath [key] browsers browsers.floorp
