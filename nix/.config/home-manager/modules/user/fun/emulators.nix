{
  pkgs,
  lib,
  config,
  ...
}:
with lib; {
  config = {
    assertions = [
      {
        assertion = (! config.features.emulators.retroarch.full) || (pkgs ? retroarchFull);
        message = "RetroArch full mode enabled but pkgs.retroarchFull is not available on this system.";
      }
    ];
    home.packages = config.lib.neg.pkgsList (
      [
        pkgs.pcem # emulator for ibm pc and clones
        pkgs.pcsx2 # ps2 emulator
      ] ++ (
        if config.features.emulators.retroarch.full
        then [pkgs.retroarchFull]
        else [pkgs.retroarch]
      )
    ); # frontend (full|free cores)
  };
}
