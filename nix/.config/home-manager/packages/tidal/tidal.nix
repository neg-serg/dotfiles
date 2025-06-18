{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  buildInputs = [
    pkgs.haskellPackages.ghc
    pkgs.haskellPackages.cabal-install
    pkgs.supercollider-with-sc3-plugins
  ];
  
  shellHook = ''
    if [ ! -d "SuperDirt" ]; then
      git clone https://github.com/musikinformatik/SuperDirt
      mkdir -p ~/.local/share/SuperCollider/downloaded-quarks/
      ln -s $PWD/SuperDirt ~/.local/share/SuperCollider/downloaded-quarks/
    fi
    cabal update
    cabal install tidal --lib
  '';
}
