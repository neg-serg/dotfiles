{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    # fontforge # font processing
    pango # for pango-list
  ];
}
