{pkgs, ...}: {
  nixpkgs = {
    config.allowUnfree = true;
    config.packageOverrides = super: {
      python3-lto = super.python3.override {
        packageOverrides = _: _: {
          enableOptimizations = true;
          enableLTO = true;
          reproducibleBuild = false;
        };
      };
    };
  };
  home.packages = with pkgs; [
    (python3-lto.withPackages (ps:
      with ps; [
        colored
        dbus-python # need for some scripts
        docopt
        fontforge # for font monospacifier
        psutil
        pynvim
        requests
        tabulate
      ]))
  ];
}
