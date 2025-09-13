{
  lib,
  config,
  pkgs,
  ...
}: let
  cachixSubstituters = import ./caches/substituters.nix;
  cachixTrustedKeys = import ./caches/trusted-public-keys.nix;
in {
  # Profile presets (full | lite). Full is default; set to "lite" for headless/minimal.
  features.profile = lib.mkDefault "full";
  # Exclude problematic packages from curated lists without editing modules
  features.excludePkgs = [
    # Network sniffing/passwords
    "dsniff"
    "crowbar"
    # Backdoor/tunneling tool candidates kept off by default
    "dns2tcp"
    "exe2hexbat"
    "laudanum"
    "mimikatz"
    "nishang"
    "powersploit"
    "ptunnel"
    "sbd"
    "shellter"
    "stunnel4"
    "veil"
    "webacoo"
    "weevely"
  ];

  # Temporarily disable Vdirsyncer units/timer until credentials are configured
  features.mail.vdirsyncer.enable = false;

  # Enable GPG stack (gpg + gpg-agent)
  features.gpg.enable = true;

  # Unfree policy centralized in modules/misc/unfree.nix (features.allowUnfree.allowed)

  nix = {
    package = pkgs.nix;
    # Per-user Nix settings
    settings = {
      # Trust flake-provided nixConfig (substituters, keys, features)
      accept-flake-config = true;
      # Use the sops-managed GitHub netrc for authenticated fetches
      netrc-file = config.sops.secrets."github-netrc".path;
      # Ensure features are available; caches and keys come from imports below
      experimental-features = ["nix-command" "flakes"];
      # Make caches visible in `nix show-config` via imported lists
      # Keep cache.nixos.org first to retain the official cache
      substituters = ["https://cache.nixos.org/"] ++ cachixSubstituters;
      trusted-public-keys =
        ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="]
        ++ cachixTrustedKeys;
    };
  };
  imports = [
    ./secrets
    ./modules
  ];
  xdg.stateHome = "${config.home.homeDirectory}/.local/state";
  home = {
    homeDirectory = "/home/neg";
    stateVersion = "23.11"; # Please read the comment before changing.
    preferXdgDirectories = true;
    username = "neg";
  };

  # Auto-push built store paths to Cachix
  services.cachix.watchStore = {
    enable = true;
    cacheName = "neg-serg";
    authTokenFile = config.sops.secrets."cachix_env".path;
  };
}
