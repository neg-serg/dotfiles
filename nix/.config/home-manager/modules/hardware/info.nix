{pkgs, config, ...}: {
  home.packages = config.lib.neg.filterByExclude (with pkgs; [
    acpi # acpi stuff
    hwinfo # suse hardware info
    inxi # show hardware
    lshw # linux hardware listner
  ]);
}
