{pkgs, ...}: {
  home.packages = with pkgs; [
    binwalk # tool library for analyzing binary blobs and executable code
    capstone
    ddrescue
    distorm3
    ext4magic
    extundelete
    ghidra-bin
    outguess # universal steganographic tool that allows the insertion of hidden information into the redundant bits of data sources
    p0f
    pdf-parser
    sleuthkit
    steghide # open source steganography program
    stegseek # tool to crack steganography
    stegsolve # steganographic image analyzer, solver and data extractor for challanges
    volatility3 # memory extraction framework
    zsteg # detect stegano-hidden data in PNG & BMP
  ];
}
