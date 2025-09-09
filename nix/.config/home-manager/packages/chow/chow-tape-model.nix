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
  gcc11,
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
  libuuid,
  libxkbcommon,
  lv2,
  pcre,
  pcre2,
  pkg-config,
  python3,
  sqlite,
  gcc11Stdenv,
  webkitgtk,
}: let
  # JUCE version in submodules is incompatible with GCC12
  # See here: https://forum.juce.com/t/build-fails-on-fedora-wrong-c-version/50902/2
  stdenv = gcc11Stdenv;
in
  stdenv.mkDerivation rec {
    pname = "ChowTapeModel";
    version = "2.11.4";

    src = fetchFromGitHub {
      owner = "jatinchowdhury18";
      repo = "AnalogTapeModel";
      rev = "v${version}";
      sha256 = "sha256-WriHi68Y6hAsrwE+74JtVlAKUR9lfTczj6UK9h2FOGM=";
      fetchSubmodules = true;
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
      libuuid # UUIDs
      libxkbcommon # keymaps
      lv2 # LV2 plugin SDK
      pcre # regex
      pcre2 # regex (v2)
      python3 # build scripts
      sqlite # database
      webkitgtk # WebKit GTK
      gcc11 # toolchain compat
    ];

    cmakeFlags = [
      "-DCMAKE_AR=${stdenv.cc.cc}/bin/gcc-ar"
      "-DCMAKE_RANLIB=${stdenv.cc.cc}/bin/gcc-ranlib"
      "-DCMAKE_NM=${stdenv.cc.cc}/bin/gcc-nm"
    ];

    cmakeBuildType = "Release";

    postPatch = ''
      cd Plugin
    '';

    installPhase = ''
      mkdir -p $out/lib/lv2 $out/lib/vst3 $out/bin $out/share/doc/CHOWTapeModel/
      cd CHOWTapeModel_artefacts/${cmakeBuildType}
      cp libCHOWTapeModel_SharedCode.a  $out/lib
      cp -r LV2/CHOWTapeModel.lv2 $out/lib/lv2
      cp -r VST3/CHOWTapeModel.vst3 $out/lib/vst3
      cp Standalone/CHOWTapeModel  $out/bin
      cp ../../../../Manual/ChowTapeManual.pdf $out/share/doc/CHOWTapeModel/
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
      homepage = "https://github.com/jatinchowdhury18/AnalogTapeModel";
      description = "Physical modelling signal processing for analog tape recording. LV2, VST3 and standalone";
      license = with licenses; [gpl3Only];
      maintainers = with maintainers; [magnetophon];
      platforms = platforms.linux;
      # error: 'vvtanh' was not declared in this scope; did you mean 'tanh'?
      # error: no matching function for call to 'juce::dsp::SIMDRegister<double>::SIMDRegister(xsimd::simd_batch_traits<xsimd::batch<double, 2> >::batch_bool_type)'
      broken = stdenv.isAarch64; # since 2021-12-27 on hydra (update to 2.10): https://hydra.nixos.org/build/162558991
    };
  }
