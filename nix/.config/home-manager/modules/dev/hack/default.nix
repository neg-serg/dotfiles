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
      config.lib.neg.pkgsList (
        config.lib.neg.mkEnabledList config.features.dev.hack.core groups
      );
  };
}
