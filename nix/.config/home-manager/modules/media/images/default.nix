{pkgs, ...}:
with {
  nsxiv-neg = pkgs.callPackage ../../../packages/nsxiv {};
}; {
  home.packages = with pkgs; [
    advancecomp # AdvanceCOMP PNG Compression Utility
    darktable # photo editing
    exiftool # extract media metadata
    exiv2 # metadata manipulation
    gcolor3 # color selector
    gpick # alternative color picker
    graphviz # graphics
    jpegoptim # jpeg optimization
    lutgen # fast lut generator
    mediainfo # another tool to extract media info
    nsxiv-neg # my favorite image viewer
    optipng # optimize png
    pastel # cli color analyze/convert/manipulation
    pngquant # convert png from RGBA to 8 bit with alpha-channel
    qrencode # qr encoding
    scour # svg optimizer
    zbar # bar code reader
  ];
}
