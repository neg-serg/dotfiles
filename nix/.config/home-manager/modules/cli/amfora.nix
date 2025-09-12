{
  pkgs,
  config,
  ...
}: {
  # Install amfora and provide its config via XDG
  home.packages = config.lib.neg.filterByExclude [pkgs.amfora];

  # Remove stale ~/.config/amfora symlink before linking
  home.activation.fixAmforaConfigDir =
    config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/amfora";

  xdg.configFile."amfora".source = ./amfora-conf;
}
