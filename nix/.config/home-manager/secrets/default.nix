{ config, lib, ... }:
let
  hasGitHubToken = builtins.pathExists ./github-token.sops.yaml;
in {
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFile = ./all.yaml;
    secrets =
      {
        # Netrc for GitHub to avoid rate limits in fetchers
        "github-netrc" = {
          format = "yaml";
          sopsFile = ./github-netrc.sops.yaml;
          key = "github-netrc";
          path = "${config.xdg.configHome}/nix/netrc";
          mode = "0400";
        };
        "mpdas_negrc" = {
          format = "binary";
          sopsFile = ./mpdas/neg.rc;
          path = "/run/user/1000/secrets/mpdas_negrc";
        };
        "musicbrainz.yaml" = {
          format = "binary";
          sopsFile = ./musicbrainz;
          path = "/run/user/1000/secrets/musicbrainz.yaml";
        };
        # Cachix token for watch-store user service (systemd EnvironmentFile format)
        "cachix_env" = {
          format = "dotenv";
          # Create and encrypt this file with sops; contents must be a single line:
          #   CACHIX_AUTH_TOKEN=... 
          sopsFile = ./cachix.env;
          path = "/run/user/1000/secrets/cachix.env";
          mode = "0400";
        };
      }
      // lib.optionalAttrs hasGitHubToken {
        # Optional: personal GitHub token for Nix access-tokens
        "github-token" = {
          format = "yaml";
          sopsFile = ./github-token.sops.yaml;
          key = "token";
          mode = "0400";
        };
      };
  };

  # Note: we intentionally avoid writing access tokens to nix.conf.
  # Authentication is handled via the sops-managed netrc referenced by nix.settings.netrc-file.
}
