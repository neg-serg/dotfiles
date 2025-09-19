{
  pkgs,
  lib,
  config,
  ...
}: let
  notBroken = p: !(((p.meta or {}).broken or false));
in {
  home.packages = lib.filter notBroken (config.lib.neg.pkgsList [
    pkgs.chirp # Configuration tool for amateur radios
    pkgs.gnuradio # GNU Radio Software Radio Toolkit
    pkgs.gqrx # Software defined radio receiver
    pkgs.hackrf # Software defined radio peripheral
    pkgs.inspectrum # Tool for visualising captured radio signals
    pkgs.kalibrate-rtl # Calculate local oscillator frequency offset using GSM base stations
    pkgs.multimon-ng # Digital radio transmission decoder
    pkgs.rtl-sdr-librtlsdr # Software to turn the RTL2832U into a SDR receiver
  ]);
  # NOT FOUND
  # gr-air-modes # Gnuradio Mode-S/ADS-B radio
  # gr-iqbal # GNU Radio Blind IQ imbalance estimator and correction
  # gr-osmosdr # Gnuradio blocks from the OsmoSDR project
}
