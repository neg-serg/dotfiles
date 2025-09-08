{ lib, config, ... }:
let
  cfg = config.features.emulators.retroarch or {};
in
{
  # When retroarchFull is enabled, allow required unfree libretro cores
  config = lib.mkIf (cfg.full or false) {
    features.allowUnfree.extra = [
      "libretro-fbalpha2012" # FBA 2012
      "libretro-fbneo" # FBNeo
      "libretro-fmsx" # MSX
      "libretro-genesis-plus-gx" # Genesis/Master System
      "libretro-mame2000" # MAME 2000
      "libretro-mame2003" # MAME 2003
      "libretro-mame2003-plus" # MAME 2003 Plus
      "libretro-mame2010" # MAME 2010
      "libretro-mame2015" # MAME 2015
      "libretro-opera" # 3DO
      "libretro-picodrive" # PicoDrive
      "libretro-snes9x" # SNES
      "libretro-snes9x2002" # SNES 2002
      "libretro-snes9x2005" # SNES 2005
      "libretro-snes9x2005-plus" # SNES 2005 Plus
      "libretro-snes9x2010" # SNES 2010
    ];
  };
}
