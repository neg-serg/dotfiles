{pkgs, config, ...}: {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    zk # notes database
  ]);
}
