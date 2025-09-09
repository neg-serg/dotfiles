{
  lib,
  boost,
  cmake,
  cxxopts,
  digestpp,
  fetchFromGitHub,
  fmt,
  jsoncons,
  pugixml,
  sqlite_orm,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "bt-migrate";
  version = "0-unstable-2025-02-28";

  src = fetchFromGitHub {
    owner = "mikedld";
    repo = "bt-migrate";
    # Latest commit on main with jsoncons API changes compatibility
    rev = "725f35e820a97176c45add333f1f47af881406f4";
    hash = "sha256-QcoenIlApmd6d1Ajd4TZdZBUmF0Q3IVeywDSwefS8FU=";
  };

  nativeBuildInputs = [
    cmake # CMake build system
  ];

  buildInputs = [
    boost # C++ libraries
    cxxopts # CLI options parser
    fmt # string formatting
    jsoncons # JSON library
    pugixml # XML library
    sqlite_orm # C++ ORM for SQLite
  ];

  cmakeFlags = [
    (lib.strings.cmakeBool "USE_VCPKG" false)
    # NOTE: digestpp does not have proper CMake packaging (yet?)
    (lib.strings.cmakeBool "USE_FETCHCONTENT" true)
    (lib.strings.cmakeFeature "FETCHCONTENT_SOURCE_DIR_DIGESTPP" "${digestpp}/include/digestpp")
  ];

  # NOTE: no install target in CMake...
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp BtMigrate $out/bin

    runHook postInstall
  '';

  meta = with lib; {
    description = "Torrent state migration tool";
    homepage = "https://github.com/mikedld/bt-migrate";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ambroisie];
    mainProgram = "BtMigrate";
  };
}
