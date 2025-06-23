{ pkgs ? import <nixpkgs> {} }:

let
  haskellEnv = pkgs.haskellPackages.ghcWithPackages (p: with p; [
    optparse-applicative
    sqlite-simple
    directory
    time
    process
  ]);
in
pkgs.mkShell {
  buildInputs = [
    haskellEnv
    pkgs.fzf
    pkgs.mpc-cli
    pkgs.sqlite
  ];

  shellHook = ''
    echo "Environment ready for MPD Manager development"
    echo "Run with: runghc madd.hs [options]"
  '';
}
