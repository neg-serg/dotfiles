{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    flashrom # Identify, read, write, erase, and verify BIOS/ROM/flash chips
    minicom # Friendly menu driven serial communication program
    openocd # Open on-chip JTAG debug solution for ARM and MIPS systems
  ];
}
