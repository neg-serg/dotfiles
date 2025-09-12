{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib; let
  qsPath = pkgs.lib.makeBinPath [
    pkgs.fd # fast file finder used by QS scripts
    pkgs.coreutils # basic CLI utilities
  ];
  quickshellWrapped = pkgs.stdenv.mkDerivation {
    name = "quickshell-wrapped";
    buildInputs = [
      pkgs.makeWrapper # provide wrapProgram for env setup
    ];
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${inputs.quickshell.packages.${pkgs.system}.default}/bin/qs $out/bin/qs \
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
  mkIf config.features.gui.enable {
    home.packages = config.lib.neg.filterByExclude (with pkgs; [
      cantarell-fonts # GNOME Cantarell fonts
      cava # console audio visualizer
      inputs.rsmetrx.packages.${pkgs.system}.default # metrics/telemetry helper
      kdePackages.kdialog # simple Qt dialog helper
      kdePackages.qt5compat # needed for Qt5Compat modules in Qt6
      kdePackages.qtdeclarative # Qt 6 QML
      kdePackages.qtimageformats # extra image formats
      kdePackages.qtmultimedia # multimedia QML/Qt
      kdePackages.qtpositioning # positioning QML/Qt
      kdePackages.qtquicktimeline # timeline QML
      kdePackages.qtsensors # sensors QML/Qt
      kdePackages.qtsvg # SVG support
      kdePackages.qttools # Qt tooling
      kdePackages.qttranslations # Qt translations
      kdePackages.qtvirtualkeyboard # on-screen keyboard
      kdePackages.qtwayland # Wayland platform plugin
      kdePackages.syntax-highlighting # KSyntaxHighlighting
      material-symbols # Material Symbols font
      networkmanager # nmcli and helpers
      qt6.qtimageformats # extra image formats (Qt6)
      qt6.qtsvg # SVG support (Qt6)
      quickshellWrapped # wrapper with required env paths
    ]);

    # Remove stale ~/.config/quickshell symlink from older generations before linking
    home.activation.fixQuickshellConfigDir =
      config.lib.neg.mkRemoveIfSymlink "${config.xdg.configHome}/quickshell";

    # Live-editable config: out-of-store symlink to repo copy
    xdg.configFile."quickshell" =
      config.lib.neg.mkDotfilesSymlink "quickshell/.config/quickshell" true;
  }
