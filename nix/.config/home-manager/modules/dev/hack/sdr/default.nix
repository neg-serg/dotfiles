{pkgs, lib, config, ...}: let
  excluded = config.features.excludePkgs or [];
  notExcluded = p: let n = (p.pname or (lib.getName p)); in !(lib.elem n excluded);
  notBroken = p: !(((p.meta or {}).broken or false));
in {
  home.packages = lib.filter notBroken (lib.filter notExcluded (with pkgs; [
    chirp # Configuration tool for amateur radios
    gnuradio # GNU Radio Software Radio Toolkit
    gqrx # Software defined radio receiver
    hackrf # Software defined radio peripheral
    inspectrum # Tool for visualising captured radio signals
    kalibrate-rtl # Calculate local oscillator frequency offset using GSM base stations
    multimon-ng # Digital radio transmission decoder
    rtl-sdr-librtlsdr # Software to turn the RTL2832U into a SDR receiver
  ]));
  # NOT FOUND
  # gr-air-modes # Gnuradio Mode-S/ADS-B radio
  # gr-iqbal # GNU Radio Blind IQ imbalance estimator and correction
  # gr-osmosdr # Gnuradio blocks from the OsmoSDR project
}
