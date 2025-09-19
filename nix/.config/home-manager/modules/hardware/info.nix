{
  pkgs,
  config,
  ...
}: {
  home.packages = config.lib.neg.pkgsList [
    pkgs.acpi # acpi stuff
    pkgs.hwinfo # suse hardware info
    pkgs.inxi # show hardware
    pkgs.lshw # linux hardware listner
  ];
}
