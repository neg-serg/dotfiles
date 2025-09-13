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
    home.packages = with pkgs; config.lib.neg.pkgsList (
        [
          pcem # emulator for ibm pc and clones
          pcsx2 # ps2 emulator
        ]
        ++ (
          if config.features.emulators.retroarch.full
          then [retroarchFull]
          else [retroarch]
        )
      ); # frontend (full|free cores)
  };
}
