{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    # fontforge # font processing
    pkgs.pango # for pango-list
  ];
}
