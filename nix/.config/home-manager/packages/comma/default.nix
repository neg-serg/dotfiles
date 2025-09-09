{
  lib,
  fzf,
  makeWrapper,
  nix-index,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "comma";
  version = "0.1.0";

  src = ./comma;

  nativeBuildInputs = [
    makeWrapper # wrap script with PATH to tools
  ];

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${meta.mainProgram}
    chmod a+x $out/bin/${meta.mainProgram}
  '';

  wrapperPath = lib.makeBinPath [
    fzf # fuzzy selector for store paths
    nix-index # locate packages providing a command
  ];

  fixupPhase = ''
    patchShebangs $out/bin/${meta.mainProgram}
    wrapProgram $out/bin/${meta.mainProgram} --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = "A simple script inspired by Shopify's comma, for modern Nix";
    homepage = "https://git.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [mit];
    mainProgram = ",";
    maintainers = with maintainers; [ambroisie];
    platforms = platforms.unix;
  };
}
