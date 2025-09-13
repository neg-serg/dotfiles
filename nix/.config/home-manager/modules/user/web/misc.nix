{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.tools.enable) {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    gallery-dl # download image galleries/collections
    monolith # download all webpage stuff as one file
    pipe-viewer # lightweight youtube client
    prettyping # fancy ping
    whois # get domain info
    xidel # download webpage parts
  ];
}
