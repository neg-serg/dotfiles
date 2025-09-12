{pkgs, config, ...}: {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    # fontforge # font processing
    pango # for pango-list
  ]);
}
