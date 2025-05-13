{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # fontforge # font processing
    pango # for pango-list
  ];
}
