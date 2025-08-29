{pkgs, ...}: {
  imports = [
    ./forensics
    ./pentest
    ./sdr
  ];
  home.packages = with pkgs; [
    binwalk # search binary image for embedded files
    capstone # disassembly framework
    gitleaks # scan repo for secrets
    git-secrets # prevents you from committing secrets and credentials into git repositories
    katana # next-generation crawling and spidering framework
  ];
}
