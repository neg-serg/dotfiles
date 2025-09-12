{
  lib,
  config,
  ...
}:
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
      formatters = config.lib.neg.mkBool "enable CLI/code formatters" true;
      codecount = config.lib.neg.mkBool "enable code counting tools" true;
      analyzers = config.lib.neg.mkBool "enable analyzers/linters" true;
      iac = config.lib.neg.mkBool "enable infrastructure-as-code tooling (Terraform, etc.)" true;
      radicle = config.lib.neg.mkBool "enable radicle tooling" true;
      runtime = config.lib.neg.mkBool "enable general dev runtimes (node etc.)" true;
      misc = config.lib.neg.mkBool "enable misc dev helpers" true;
    };
    hack = {
      core = {
        secrets = config.lib.neg.mkBool "enable git secret scanners" true;
        reverse = config.lib.neg.mkBool "enable reverse/disasm helpers" true;
        crawl = config.lib.neg.mkBool "enable web crawling tools" true;
      };
      forensics = {
        fs = config.lib.neg.mkBool "enable FS/disk forensics" true;
        stego = config.lib.neg.mkBool "enable steganography tools" true;
        analysis = config.lib.neg.mkBool "enable reverse/binary analysis" true;
        network = config.lib.neg.mkBool "enable network forensics" true;
      };
    };
    python = {
      core = config.lib.neg.mkBool "enable core Python dev packages" true;
      tools = config.lib.neg.mkBool "enable Python tooling (LSP, utils)" true;
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
