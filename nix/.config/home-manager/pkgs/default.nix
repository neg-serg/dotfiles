{ ... }: {
    imports = [
        ./android.nix
        ./archives.nix
        ./audio
        ./benchmarks.nix
        ./btop.nix
        ./cli.nix
        ./dev.nix
        ./distros.nix
        ./fetch.nix
        ./fonts
        ./fun
        ./gpg.nix
        ./hack.nix
        ./hardware
        ./im
        ./images
        ./mail.nix
        ./media
        ./neovim.nix
        ./pass.nix
        ./python
        ./sway.nix
        ./terminal
        ./text
        ./torrent
        ./vulnerability_scanners.nix
        ./web
        ./x11
        ./yubikey.nix

        ./misc.nix
    ];
}