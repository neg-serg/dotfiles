{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    sqlite # self-contained, serverless, zero-configuration, transactional SQL database engine
  ]);
}
