{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.cachix.watchStore;
in {
  options.services.cachix.watchStore = {
    enable = lib.mkEnableOption "Run cachix watch-store as a user service";

    cacheName = lib.mkOption {
      type = lib.types.str;
      example = "my-cachix-cache";
      description = "Cachix cache name to push paths to.";
    };

    authTokenFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/user/1000/secrets/cachix.env";
      description = ''
        Optional EnvironmentFile for systemd with CACHIX_AUTH_TOKEN=... line.
        If null, cachix will use tokens configured by `cachix authtoken`.
      '';
    };

    requireAuthFile = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "If true, fail the unit when auth token file is missing.";
    };

    ownCache = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Add this cache to Nix substituters and trusted keys.";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "neg-serg";
        description = "Your Cachix cache name (without URL).";
      };
      publicKey = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "neg-serg.cachix.org-1:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        description = "Public signing key for your Cachix cache (from Cachix UI).";
      };
    };

    hardening = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Apply systemd hardening options to the service.";
      };
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["--push-filter" ".*\.drv$"];
      description = "Additional arguments passed to `cachix watch-store`.";
    };
  };

  config = lib.mkIf config.features.dev.enable {
    home.packages = lib.mkIf (cfg.enable || cfg.ownCache.enable) [pkgs.cachix];

    nix.settings = lib.mkIf cfg.ownCache.enable {
      substituters = [("https://" + cfg.ownCache.name + ".cachix.org")];
      trusted-public-keys = [cfg.ownCache.publicKey];
    };

    systemd.user.services."cachix-watch-store" = lib.mkIf cfg.enable {
      Unit = {
        Description = "Cachix watch-store for ${cfg.cacheName}";
        After = [
          "network-online.target" # require working network
          "sops-nix.service" # ensure secrets available if needed
        ];
        Wants = [
          "network-online.target" # pull in network-online
          "sops-nix.service" # pull in secrets availability
        ];
      };
      Service = {
        Type = "simple";
        EnvironmentFile =
          lib.mkIf (cfg.authTokenFile != null)
          (
            if cfg.requireAuthFile
            then cfg.authTokenFile
            else ("-" + cfg.authTokenFile)
          );
        ExecStartPre = lib.mkIf (cfg.authTokenFile != null && cfg.requireAuthFile) ''
          ${pkgs.bash}/bin/bash -c 'if ! grep -q "^CACHIX_AUTH_TOKEN=" ${cfg.authTokenFile}; then echo "CACHIX_AUTH_TOKEN not set in ${cfg.authTokenFile}"; exit 1; fi'
        '';
        ExecStart = lib.concatStringsSep " " ([
            "${lib.getBin pkgs.cachix}/bin/cachix"
            "watch-store"
            cfg.cacheName
          ]
          ++ cfg.extraArgs);
        Restart = "always";
        RestartSec = 10;

        # Optional hardening
        NoNewPrivileges = lib.mkIf cfg.hardening.enable true;
        PrivateTmp = lib.mkIf cfg.hardening.enable true;
        PrivateDevices = lib.mkIf cfg.hardening.enable true;
        ProtectControlGroups = lib.mkIf cfg.hardening.enable true;
        # Need read access to $HOME because the secret path is a symlink into ~/.config/sops-nix
        ProtectHome = lib.mkIf cfg.hardening.enable "read-only";
        ProtectKernelModules = lib.mkIf cfg.hardening.enable true;
        ProtectKernelTunables = lib.mkIf cfg.hardening.enable true;
        ProtectSystem = lib.mkIf cfg.hardening.enable "strict";
        RestrictNamespaces = lib.mkIf cfg.hardening.enable true;
        RestrictSUIDSGID = lib.mkIf cfg.hardening.enable true;
        LockPersonality = lib.mkIf cfg.hardening.enable true;
        MemoryDenyWriteExecute = lib.mkIf cfg.hardening.enable true;
        CapabilityBoundingSet = lib.mkIf cfg.hardening.enable [""];
        RestrictAddressFamilies = lib.mkIf cfg.hardening.enable ["AF_INET" "AF_INET6"];
      };
      Install = {
        WantedBy = [
          "default.target" # start by default in user session
        ];
      };
    };
  };
}
