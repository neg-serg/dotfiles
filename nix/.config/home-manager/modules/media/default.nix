{ ... }: {
  imports = [
    ./apps.nix
    ./audio
    ./images
    ./mpv.nix
    ./pipewire.nix
    ./playerctld.nix
  ];
  # moved to playerctld.nix and pipewire.nix
}
