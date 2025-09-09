{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  groups = with pkgs; rec {
    secrets = [
      gitleaks # scan repositories for secrets
      git-secrets # prevent committing secrets to git
    ];
    reverse = [
      binwalk # analyze binaries for embedded files
      capstone # disassembly framework
    ];
    crawl = [
      katana # modern web crawler/spider
    ];
  };
in {
  imports = [
    ./forensics
    ./pentest
    ./sdr
  ];
  config = mkIf (config.features.dev.enable && config.features.hack.enable) {
    home.packages =
      (optionals config.features.dev.hack.core.secrets groups.secrets)
      ++ (optionals config.features.dev.hack.core.reverse groups.reverse)
      ++ (optionals config.features.dev.hack.core.crawl groups.crawl);
  };
}
