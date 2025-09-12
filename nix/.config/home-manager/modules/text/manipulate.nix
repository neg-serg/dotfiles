{
  pkgs,
  config,
  ...
}: {
  programs.jqp.enable = true; # interactive jq
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    gron # greppable json
    htmlq # jq for html
    jc # convert something to json or yaml
    jq # json magic
    pup # html parser from commandline
    yq-go # jq for yaml
  ]);
}
