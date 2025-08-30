{ config, lib, pkgs, ... }:
let
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

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["--push-filter" ".*\.drv$"]; 
      description = "Additional arguments passed to `cachix watch-store`.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.cachix ];

    systemd.user.services."cachix-watch-store" = {
      Unit = {
        Description = "Cachix watch-store for ${cfg.cacheName}";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "simple";
        # Use token from file if provided (expects CACHIX_AUTH_TOKEN=... in dotenv format)
        # Prefix with '-' to make it optional if the file is missing
        EnvironmentFile = lib.mkIf (cfg.authTokenFile != null) ("-" + cfg.authTokenFile);
        ExecStart = lib.concatStringsSep " " ([
          "${lib.getBin pkgs.cachix}/bin/cachix"
          "watch-store"
          cfg.cacheName
        ] ++ cfg.extraArgs);
        Restart = "always";
        RestartSec = 10;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
