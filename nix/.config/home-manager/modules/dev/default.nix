{lib, ...}:
with lib; {
  options.features.dev = {
    iac = {
      backend = mkOption {
        type = types.enum ["terraform" "tofu"];
        default = "terraform";
        description = "Choose IaC backend: HashiCorp Terraform or OpenTofu (tofu).";
      };
    };
    pkgs = {
      formatters = mkEnableOption "enable CLI/code formatters" // {default = true;};
      codecount = mkEnableOption "enable code counting tools" // {default = true;};
      analyzers = mkEnableOption "enable analyzers/linters" // {default = true;};
      iac = mkEnableOption "enable infrastructure-as-code tooling (Terraform, etc.)" // {default = true;};
      radicle = mkEnableOption "enable radicle tooling" // {default = true;};
      runtime = mkEnableOption "enable general dev runtimes (node etc.)" // {default = true;};
      misc = mkEnableOption "enable misc dev helpers" // {default = true;};
    };
    hack = {
      core = {
        secrets = mkEnableOption "enable git secret scanners" // {default = true;};
        reverse = mkEnableOption "enable reverse/disasm helpers" // {default = true;};
        crawl = mkEnableOption "enable web crawling tools" // {default = true;};
      };
      forensics = {
        fs = mkEnableOption "enable FS/disk forensics" // {default = true;};
        stego = mkEnableOption "enable steganography tools" // {default = true;};
        analysis = mkEnableOption "enable reverse/binary analysis" // {default = true;};
        network = mkEnableOption "enable network forensics" // {default = true;};
      };
    };
    python = {
      core = mkEnableOption "enable core Python dev packages" // {default = true;};
      tools = mkEnableOption "enable Python tooling (LSP, utils)" // {default = true;};
    };
  };

  imports = [
    ./android
    ./benchmarks
    ./cachix
    ./ansible
    ./editor
    ./git
    ./gdb
    ./hack
    ./pkgs
    ./python
  ];
}
