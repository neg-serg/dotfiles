{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.filterByExclude [pkgs.fuzzel];
  # Remove stale ~/.config/fuzzel symlink before linking
  home.activation.fixFuzzelConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/fuzzel";
  xdg.configFile."fuzzel".source = ./fuzzel-conf;
}
