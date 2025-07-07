{
  description = "flake for blissify-rs (Rust CLI)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
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

        blissify-rs = pkgs.rustPlatform.buildRustPackage.override { inherit stdenv; } {
          name = "blissify-rs";
          pname = "blissify-rs";
          src = blissify-rs-src;

          nativeBuildInputs = [ 
            pkgs.pkg-config 
            pkgs.cmake
          ];
          
          buildInputs = [
            pkgs.ffmpeg
            pkgs.llvmPackages.libclang
            pkgs.stdenv.cc.cc.lib
            pkgs.sqlite
            pkgs.libcxx
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

      in
      {
        packages = {
          default = blissify-rs;
          blissify-rs = blissify-rs;
          blissify-rs-src = blissify-rs-src;
        };

        devShells.default = pkgs.mkShell.override { inherit stdenv; } {
          nativeBuildInputs = [ 
            pkgs.pkg-config 
            pkgs.cmake
          ];
          
          buildInputs = with pkgs; [
            rustc
            cargo
            rust-analyzer
            ffmpeg
            stdenv.cc.cc.lib
            stdenv.cc.libc.dev
            llvmPackages.libclang
            sqlite  # Add SQLite to dev shell
            clang
            libcxx
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
