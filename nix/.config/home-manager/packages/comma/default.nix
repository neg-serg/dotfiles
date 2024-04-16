{ lib, fzf, makeWrapper, nix-index, stdenvNoCC }:
stdenvNoCC.mkDerivation rec {
  pname = "comma";
  version = "0.1.0";

  src = ./comma;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${meta.mainProgram}
    chmod a+x $out/bin/${meta.mainProgram}
  '';

  wrapperPath = lib.makeBinPath [
    fzf
    nix-index
  ];

  fixupPhase = ''
    patchShebangs $out/bin/${meta.mainProgram}
    wrapProgram $out/bin/${meta.mainProgram} --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = "A simple script inspired by Shopify's comma, for modern Nix";
    homepage = "https://git.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    mainProgram = ",";
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.unix;
  };
}
