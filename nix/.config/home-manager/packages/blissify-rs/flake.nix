{
  description = "flake for blissify-rs (Rust CLI)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        # Use clang-based stdenv for better C++ compatibility
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [];
        };
      };

      stdenv = pkgs.clangStdenv;
      clang = pkgs.llvmPackages.clang-unwrapped;

      blissify-rs-src = pkgs.fetchgit {
        url = "https://github.com/Polochon-street/blissify-rs.git";
        rev = "a0ad533d252f0a7d741496f5fbeec2f38862f795";
        sha256 = "sha256-QYm/vSMhS8sdAcN60FBbjvdiNlvf0Tmj4t1OtpsglcI=";
      };

      blissify-rs = pkgs.rustPlatform.buildRustPackage.override {inherit stdenv;} {
        name = "blissify-rs";
        pname = "blissify-rs";
        src = blissify-rs-src;

        nativeBuildInputs = [
          pkgs.pkg-config # discover C libraries/flags
          pkgs.cmake # build helper for C deps
        ];

        buildInputs = [
          pkgs.ffmpeg # audio decoding
          pkgs.llvmPackages.libclang # headers for bindgen
          pkgs.stdenv.cc.cc.lib # libstdc++ (or platform libc++)
          pkgs.sqlite # embedded DB
          pkgs.libcxx # libc++ runtime
        ];

        # Explicitly set all required header paths
        env = {
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          C_INCLUDE_PATH = "${pkgs.stdenv.cc.libc.dev}/include:${clang}/lib/clang/${clang.version}/include";
          BINDGEN_EXTRA_CLANG_ARGS = builtins.concatStringsSep " " [
            "-isystem ${pkgs.stdenv.cc.cc}/include"
            "-isystem ${pkgs.stdenv.cc.libc.dev}/include"
            "-isystem ${clang}/lib/clang/${clang.version}/include"
          ];
        };

        cargoLock = {
          lockFile = "${blissify-rs-src}/Cargo.lock";
        };

        meta = with pkgs.lib; {
          description = "Automatic playlist generator written in Rust";
          homepage = "https://github.com/Polochon-street/blissify-rs";
          license = licenses.mit;
        };
      };
    in {
      packages = {
        default = blissify-rs;
        inherit blissify-rs;
        inherit blissify-rs-src;
      };

      devShells.default = pkgs.mkShell.override {inherit stdenv;} {
        nativeBuildInputs = [
          pkgs.pkg-config # discover C libraries/flags
          pkgs.cmake # build helper for C deps
        ];

        buildInputs = with pkgs; [
          rustc # Rust compiler
          cargo # package manager/build tool
          rust-analyzer # IDE language server
          ffmpeg # audio decoding
          stdenv.cc.cc.lib # libstdc++
          stdenv.cc.libc.dev # libc headers
          llvmPackages.libclang # headers for bindgen
          sqlite # database client/libs
          clang # C/CPP compiler
          libcxx # libc++ runtime
        ];

        shellHook = ''
          export LIBCLANG_PATH=${pkgs.llvmPackages.libclang.lib}/lib
          export C_INCLUDE_PATH="${pkgs.stdenv.cc.libc.dev}/include:${clang}/lib/clang/${clang.version}/include"
          export BINDGEN_EXTRA_CLANG_ARGS="\
            -isystem ${pkgs.stdenv.cc.cc}/include \
            -isystem ${pkgs.stdenv.cc.libc.dev}/include \
            -isystem ${clang}/lib/clang/${clang.version}/include"

          echo
          echo "✅ Rust devShell for blissify-rs ready."
          echo
        '';
      };
    });
}
