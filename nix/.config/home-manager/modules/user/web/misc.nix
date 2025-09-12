{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf (config.features.web.enable && config.features.web.tools.enable) {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    gallery-dl # download image galleries/collections
    monolith # download all webpage stuff as one file
    pipe-viewer # lightweight youtube client
    prettyping # fancy ping
    whois # get domain info
    xidel # download webpage parts
  ]);
}
