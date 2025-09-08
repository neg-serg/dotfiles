{ pkgs, lib, config, ... }:
let
  groups = with pkgs; rec {
    fs = [
      ddrescue # data recovery utility
      ext4magic # recover deleted files from ext4
      extundelete # undelete files from ext3/ext4
      sleuthkit # filesystem forensics toolkit
    ];
    stego = [
      outguess # universal steganography tool
      steghide # hide/extract data in images/audio
      stegseek # crack steghide passwords fast
      stegsolve # image steganography analyzer/solver
      zsteg # detect hidden data in PNG/BMP
    ];
    analysis = [
      ghidra-bin # reverse engineering suite
      binwalk # scan binaries for embedded files
      capstone # multi-arch disassembly engine
      volatility3 # memory forensics framework
      pdf-parser # analyze/parse PDF documents
    ];
    network = [
      p0f # passive OS/network fingerprinting
    ];
  };
in {
  home.packages = config.lib.neg.mkEnabledList config.features.dev.hack.forensics groups;
}
