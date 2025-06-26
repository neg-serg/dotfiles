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
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.fd pkgs.coreutils ]}
    '';
  };
in
{
  home.packages = [ quickshellWrapped ];
}
