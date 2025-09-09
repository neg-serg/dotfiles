{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cairo,
  glib,
  pango,
}:
rustPlatform.buildRustPackage rec {
  pname = "rofi-games";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "Rolv-Apneseth";
    repo = "rofi-games";
    rev = "v${version}";
    hash = "sha256-0QTUuf33EdGhFssFyVjjSE84SUfJT8kZeBcM5JzunBo=";
  };

  cargoHash = "sha256-c1MV1QRsDJCh55rST/m17P37pCAvyi98+QbrVqwVfpM=";

  nativeBuildInputs = [
    pkg-config # discover C libs for build
  ];

  buildInputs = [
    cairo # 2D graphics
    glib # core GNOME/GLib utils
    pango # text layout
  ];

  meta = with lib; {
    description = "A rofi plugin which adds a mode that will list available games for launch along with their box art. Requires a good theme for the best results";
    homepage = "https://github.com/Rolv-Apneseth/rofi-games";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [];
    mainProgram = "rofi-games";
  };
}
