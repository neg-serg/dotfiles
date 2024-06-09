{ lib, coreutils, gnused, makeWrapper, stdenvNoCC, xorg }:
stdenvNoCC.mkDerivation rec {
  pname = "i3-get-window-criteria";
  version = "0.1.0";

  src = ./i3-get-window-criteria;

  nativeBuildInputs = [
    makeWrapper
  ];

  dontUnpack = true;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/${pname}
    chmod a+x $out/bin/${pname}
  '';

  wrapperPath = lib.makeBinPath [
    coreutils
    gnused
    xorg.xprop
    xorg.xwininfo
  ];

  fixupPhase = ''
    patchShebangs $out/bin/${pname}
    wrapProgram $out/bin/${pname} --prefix PATH : "${wrapperPath}"
  '';

  meta = with lib; {
    description = "Helper script to query i3 window criterions";
    homepage = "https://git.belanyi.fr/ambroisie/nix-config";
    license = with licenses; [ mit ];
    mainProgram = "i3-get-window-criteria";
    maintainers = with maintainers; [ ambroisie ];
    platforms = platforms.unix;
  };
}
