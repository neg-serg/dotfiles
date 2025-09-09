{
  alsa-lib,
  at-spi2-core,
  cmake,
  curl,
  dbus,
  libepoxy,
  fetchFromGitHub,
  freeglut,
  freetype,
  gtk3,
  lib,
  libGL,
  libXcursor,
  libXdmcp,
  libXext,
  libXinerama,
  libXrandr,
  libXtst,
  libdatrie,
  libjack2,
  libpsl,
  libselinux,
  libsepol,
  libsysprof-capture,
  libthai,
  libxkbcommon,
  pcre,
  pkg-config,
  python3,
  sqlite,
  stdenv,
}:
stdenv.mkDerivation rec {
  pname = "ChowPhaser";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "jatinchowdhury18";
    repo = "ChowPhaser";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "sha256-9wo7ZFMruG3QNvlpILSvrFh/Sx6J1qnlWc8+aQyS4tQ=";
  };

  nativeBuildInputs = [
    pkg-config # locate system libraries
    cmake # build system
  ];

  buildInputs = [
    alsa-lib # ALSA audio
    at-spi2-core # a11y bus
    curl # HTTP client
    dbus # D-Bus IPC
    libepoxy # GL dispatch
    freeglut # OpenGL utility toolkit
    freetype # font rendering
    gtk3 # GUI toolkit
    libGL # OpenGL
    libXcursor # X11 cursor
    libXdmcp # X11 display mgmt
    libXext # X11 extensions
    libXinerama # Xinerama
    libXrandr # RandR
    libXtst # XTest
    libdatrie # trie lib (thai)
    libjack2 # JACK audio
    libpsl # PSL for libcurl
    libselinux # SELinux libs
    libsepol # SELinux policy
    libsysprof-capture # profiling
    libthai # Thai support
    libxkbcommon # keymaps
    pcre # regex
    python3 # build scripts
    sqlite # database
  ];

  cmakeFlags = [
    "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
    "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
    "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
  ];

  installPhase = ''
    mkdir -p $out/lib/lv2 $out/lib/vst3 $out/bin $out/share/doc/ChowPhaser/
    cd ChowPhaserMono_artefacts/Release
    cp libChowPhaserMono_SharedCode.a  $out/lib
    cp -r VST3/ChowPhaserMono.vst3 $out/lib/vst3
    cp Standalone/ChowPhaserMono  $out/bin
    cd ../../ChowPhaserStereo_artefacts/Release
    cp libChowPhaserStereo_SharedCode.a  $out/lib
    cp -r VST3/ChowPhaserStereo.vst3 $out/lib/vst3
    cp Standalone/ChowPhaserStereo  $out/bin
  '';

  # JUCE dlopens these, make sure they are in rpath
  # Otherwise, segfault will happen
  NIX_LDFLAGS = toString [
    "-lX11"
    "-lXext"
    "-lXcursor"
    "-lXinerama"
    "-lXrandr"
  ];

  meta = with lib; {
    homepage = "https://github.com/jatinchowdhury18/ChowPhaser";
    description = "Phaser effect based loosely on the Schulte Compact Phasing 'A'";
    license = with licenses; [bsd3];
    maintainers = with maintainers; [magnetophon];
    platforms = platforms.linux;
  };
}
