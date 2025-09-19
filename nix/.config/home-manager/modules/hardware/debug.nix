{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.flashrom # Identify, read, write, erase, and verify BIOS/ROM/flash chips
    pkgs.minicom # Friendly menu driven serial communication program
    pkgs.openocd # Open on-chip JTAG debug solution for ARM and MIPS systems
  ];
}
