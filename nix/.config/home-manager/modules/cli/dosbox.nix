{
  pkgs,
  config,
  ...
}: {
  # Install dosbox-staging and ship config via XDG
  home.packages = config.lib.neg.filterByExclude [pkgs.dosbox-staging];

  # Remove stale ~/.config/dosbox symlink before linking
  home.activation.fixDosboxConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/dosbox";

  xdg.configFile."dosbox".source = ./dosbox-conf;
}
