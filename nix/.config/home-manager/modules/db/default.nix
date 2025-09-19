{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.sqlite # self-contained, serverless, transactional SQL DB
    pkgs.pgcli # PostgreSQL TUI client (client-only; no server)
    pkgs.iredis # Redis enhanced CLI (client-only; no server)
  ];
}
