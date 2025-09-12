{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.filterByExclude [pkgs.handlr];
  # Remove stale ~/.config/handlr symlink before linking
  home.activation.fixHandlrConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/handlr";
  xdg.configFile."handlr".source = ./handlr-conf;
}
