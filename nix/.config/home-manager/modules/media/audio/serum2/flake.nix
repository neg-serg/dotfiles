{
  description = "Serum 2 + yabridge + DXVK + Wine on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        wineEnv = pkgs.mkShell {
          name = "serum2-env";

          buildInputs = with pkgs; [
            wineWowPackages.staging
            winetricks
            dxvk
            vkd3d
            yabridge
            yabridgectl
            vulkan-tools
            glxinfo
            pavucontrol
            alsa-lib
            libpulseaudio
          ];

          WINEPREFIX = "/home/neg/.local/share/wineprefixes/serum2";
          shellHook = ''
            export WINEPREFIX=$WINEPREFIX
            export DXVK_HUD=1
            export DXVK_LOG_LEVEL=info
            export WINEDEBUG=-all

            echo "\n✅ Ready to install or launch Serum 2!"
            echo "Use: wine setup.exe to install"
            echo "Then: yabridgectl add $WINEPREFIX/drive_c/VSTPlugins && yabridgectl sync"
          '';
        };
      in
        {
          devShell = wineEnv;
        });
}
