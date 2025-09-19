{
  lib,
  ...
}:
with lib; let mkBool = desc: default: (lib.mkEnableOption desc) // { inherit default; };
in {
  options.features.dev = {
    iac = {
      backend = mkOption {
        type = types.enum ["terraform" "tofu"];
        default = "terraform";
        description = "Choose IaC backend: HashiCorp Terraform or OpenTofu (tofu).";
      };
    };
    pkgs = {
      formatters = mkBool "enable CLI/code formatters" true;
      codecount = mkBool "enable code counting tools" true;
      analyzers = mkBool "enable analyzers/linters" true;
      iac = mkBool "enable infrastructure-as-code tooling (Terraform, etc.)" true;
      radicle = mkBool "enable radicle tooling" true;
      runtime = mkBool "enable general dev runtimes (node etc.)" true;
      misc = mkBool "enable misc dev helpers" true;
    };
    hack = {
      core = {
        secrets = mkBool "enable git secret scanners" true;
        reverse = mkBool "enable reverse/disasm helpers" true;
        crawl = mkBool "enable web crawling tools" true;
      };
      forensics = {
        fs = mkBool "enable FS/disk forensics" true;
        stego = mkBool "enable steganography tools" true;
        analysis = mkBool "enable reverse/binary analysis" true;
        network = mkBool "enable network forensics" true;
      };
    };
    python = {
      core = mkBool "enable core Python dev packages" true;
      tools = mkBool "enable Python tooling (LSP, utils)" true;
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
