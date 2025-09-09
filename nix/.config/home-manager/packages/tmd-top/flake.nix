{
  description = "tmd-top packaged as a Nix flake (Python app)";

  inputs = {
    # Follow user's system nixpkgs via flake registry
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
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
          nativeBuildInputs = [
            pyPkgs.poetry-core # PEP 517 build backend for Textual
          ];
          propagatedBuildInputs = [
            pyPkgs.rich # terminal rendering primitives
            pyPkgs."typing-extensions" # typing backports for older Python
            pyPkgs."markdown-it-py" # Markdown parser
            pyPkgs."linkify-it-py" # URL/link detection
            pyPkgs."uc-micro-py" # Unicode categories (for linkify/md)
            pyPkgs."mdit-py-plugins" # Markdown-it plugins
            pyPkgs.pygments # syntax highlighting
            pyPkgs.platformdirs # cross‑platform config/cache dirs
          ];
          doCheck = false;
        };

        tmd-top = pyPkgs.buildPythonApplication {
          pname = "tmd-top";
          version = "2.2.0";
          format = "setuptools"; # project uses setup.py
          src = ./.;

          propagatedBuildInputs = [
            textualPinned # TUI framework
            pyPkgs.rich # rich text output
            pyPkgs.geoip2 # IP geolocation database access
            pyPkgs."typing-extensions" # typing backports
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
            python # Python interpreter for dev
            textualPinned # TUI framework
            pyPkgs.rich # terminal rendering
            pyPkgs.geoip2 # GeoIP lib for testing
            pyPkgs."typing-extensions" # typing backports
          ];
        };
      }
    );
}
