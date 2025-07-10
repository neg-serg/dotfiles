{ pkgs, inputs, ... }:
let
  quickshellWrapped = pkgs.stdenv.mkDerivation {
    name = "quickshell-wrapped";
    buildInputs = [ pkgs.makeWrapper ];
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
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.fd pkgs.coreutils ]}
    '';
  };
in
{
  home.packages = with pkgs; [
    kdePackages.kdialog
    kdePackages.qt5compat # needed for Qt5Compat modules in Qt6
    kdePackages.qtdeclarative # Qt6
    kdePackages.qtimageformats
    kdePackages.qtmultimedia
    kdePackages.qtpositioning
    kdePackages.qtquicktimeline
    kdePackages.qtsensors
    kdePackages.qtsvg
    kdePackages.qttools
    kdePackages.qttranslations
    kdePackages.qtvirtualkeyboard
    kdePackages.qtwayland
    kdePackages.syntax-highlighting
    qt6.qtimageformats
    qt6.qtsvg
    quickshellWrapped
  ];
}
