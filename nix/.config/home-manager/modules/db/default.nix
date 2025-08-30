{pkgs, ...}: {
  home.packages = with pkgs; [
    sqlite # self-contained, serverless, zero-configuration, transactional SQL database engine
  ];
}
