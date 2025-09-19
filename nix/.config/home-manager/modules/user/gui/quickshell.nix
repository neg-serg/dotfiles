{ lib, pkgs, config, xdg, qsProvider ? null, rsmetrxProvider ? null, ... }:
with lib; let
  qsPath = pkgs.lib.makeBinPath [
    pkgs.fd # fast file finder used by QS scripts
    pkgs.coreutils # basic CLI utilities
  ];
  qsBin = let qs = if qsProvider != null then (qsProvider pkgs) else pkgs.emptyFile; in lib.getExe' qs "qs";
  quickshellWrapped = pkgs.stdenv.mkDerivation {
    name = "quickshell-wrapped";
    buildInputs = [
      pkgs.makeWrapper # provide wrapProgram for env setup
    ];
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${qsBin} $out/bin/qs \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtbase}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qt5compat}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtdeclarative}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtpositioning}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.kdePackages.syntax-highlighting}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix QT_PLUGIN_PATH : "${pkgs.qt6.qtmultimedia}/${pkgs.qt6.qtbase.qtPluginPrefix}" \
        --prefix QML2_IMPORT_PATH : "${pkgs.qt6.qtmultimedia}/${pkgs.qt6.qtbase.qtQmlPrefix}" \
        --prefix PATH : ${qsPath}
    '';
  };
in
  mkIf (config.features.gui.enable && (config.features.gui.qt.enable or false) && (! (config.features.devSpeed.enable or false))) (lib.mkMerge [
    {
      home.packages = config.lib.neg.pkgsList [
      pkgs.cantarell-fonts # GNOME Cantarell fonts
      pkgs.cava # console audio visualizer
      (if rsmetrxProvider != null then (rsmetrxProvider pkgs) else pkgs.emptyFile) # metrics/telemetry helper
      pkgs.kdePackages.kdialog # simple Qt dialog helper
      pkgs.kdePackages.qt5compat # needed for Qt5Compat modules in Qt6
      pkgs.kdePackages.qtdeclarative # Qt 6 QML
      pkgs.kdePackages.qtimageformats # extra image formats
      pkgs.kdePackages.qtmultimedia # multimedia QML/Qt
      pkgs.kdePackages.qtpositioning # positioning QML/Qt
      pkgs.kdePackages.qtquicktimeline # timeline QML
      pkgs.kdePackages.qtsensors # sensors QML/Qt
      pkgs.kdePackages.qtsvg # SVG support
      pkgs.kdePackages.qttools # Qt tooling
      pkgs.kdePackages.qttranslations # Qt translations
      pkgs.kdePackages.qtvirtualkeyboard # on-screen keyboard
      pkgs.kdePackages.qtwayland # Wayland platform plugin
      pkgs.kdePackages.syntax-highlighting # KSyntaxHighlighting
      pkgs.material-symbols # Material Symbols font
      pkgs.networkmanager # nmcli and helpers
      pkgs.qt6.qtimageformats # extra image formats (Qt6)
        pkgs.qt6.qtsvg # SVG support (Qt6)
        quickshellWrapped # wrapper with required env paths
      ];
    }
    # Live-editable config via helper (guards parent dir and target)
  (xdg.mkXdgSource "quickshell" {
    source = config.lib.file.mkOutOfStoreSymlink "${config.neg.dotfilesRoot}/quickshell/.config/quickshell";
    recursive = true;
  })
  ])
