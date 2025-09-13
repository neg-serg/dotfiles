{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; config.lib.neg.pkgsList [
    acpi # acpi stuff
    hwinfo # suse hardware info
    inxi # show hardware
    lshw # linux hardware listner
  ];
}
