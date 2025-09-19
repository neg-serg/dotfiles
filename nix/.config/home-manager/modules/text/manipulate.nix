{
  pkgs,
  config,
  ...
}: {
  programs.jqp.enable = true; # interactive jq
  home.packages = config.lib.neg.pkgsList [
    pkgs.gron # greppable json
    pkgs.htmlq # jq for html
    pkgs.jc # convert something to json or yaml
    pkgs.jq # json magic
    pkgs.pup # html parser from commandline
    pkgs.yq-go # jq for yaml
  ];
}
