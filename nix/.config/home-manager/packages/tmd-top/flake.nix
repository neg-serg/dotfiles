{
  description = "tmd-top packaged as a Nix flake (Python app)";

  inputs = {
    # Follow user's system nixpkgs via flake registry
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
        lib = pkgs.lib;
        python = pkgs.python3; # use default python3 for this channel
        pyPkgs = python.pkgs;

        # Pin textual to 1.0.0 to match upstream requirements
        textualPinned = pyPkgs.buildPythonPackage rec {
          pname = "textual";
          version = "1.0.0";
          format = "pyproject";
          src = pkgs.fetchPypi {
            inherit pname version;
            hash = "sha256-vsn+Y1R8HFUladG3XTCQOLfUVsA/ht+jcG3bCZsVE5k=";
          };
          nativeBuildInputs = [pyPkgs.poetry-core];
          propagatedBuildInputs = [
            pyPkgs.rich
            pyPkgs."typing-extensions"
            pyPkgs."markdown-it-py"
            pyPkgs."linkify-it-py"
            pyPkgs."uc-micro-py"
            pyPkgs."mdit-py-plugins"
            pyPkgs.pygments
            pyPkgs.platformdirs
          ];
          doCheck = false;
        };

        tmd-top = pyPkgs.buildPythonApplication {
          pname = "tmd-top";
          version = "2.2.0";
          format = "setuptools"; # project uses setup.py
          src = ./.;

          propagatedBuildInputs = [
            textualPinned
            pyPkgs.rich
            pyPkgs.geoip2
            pyPkgs."typing-extensions"
          ];

          # no tests provided; disable pytest check phase
          doCheck = false;

          # Provide required external tools at runtime
          makeWrapperArgs = [
            "--prefix"
            "PATH"
            ":"
            (pkgs.lib.makeBinPath [
              pkgs.iproute2 # ss
              pkgs.procps # ps
              pkgs.coreutils # cat, sleep
              pkgs.iptables # optional: for block feature
            ])
          ];

          meta = with pkgs.lib; {
            description = "Linux network traffic TUI analyzer (per-connection)";
            homepage = "https://gitee.com/Davin168/tmd-top";
            license = licenses.mit;
            mainProgram = "tmd-top";
            platforms = platforms.linux;
          };
        };
      in {
        packages.default = tmd-top;

        apps.default = {
          type = "app";
          program = "${tmd-top}/bin/tmd-top";
        };

        devShells.default = pkgs.mkShell {
          packages = [
            python
            textualPinned
            pyPkgs.rich
            pyPkgs.geoip2
            pyPkgs."typing-extensions"
          ];
        };
      }
    );
}
