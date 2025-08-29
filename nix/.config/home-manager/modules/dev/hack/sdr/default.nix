{pkgs, ...}: {
  home.packages = with pkgs; [
    chirp # Configuration tool for amateur radios
    gnuradio # GNU Radio Software Radio Toolkit
    gqrx # Software defined radio receiver
    gr-air-modes # Gnuradio Mode-S/ADS-B radio
    gr-iqbal # GNU Radio Blind IQ imbalance estimator and correction
    gr-osmosdr # Gnuradio blocks from the OsmoSDR project
    hackrf # Software defined radio peripheral
    inspectrum # Tool for visualising captured radio signals
    kalibrate-rtl # Calculate local oscillator frequency offset using GSM base stations
    multimon-ng # Digital radio transmission decoder
    rtlsdr-scanner # Simple spectrum analyser for scanning with a RTL-SDR compatible USB device
    uhd-host # Universal hardware driver for Ettus Research products - host apps
    uhd-images # Various UHD Images
  ];
}
