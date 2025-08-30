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

  # Inject access-tokens into user nix.conf at activation if token exists
  home.activation = lib.mkIf hasGitHubToken {
    nixAccessToken = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      token="$(cat ${config.sops.secrets."github-token".path} 2>/dev/null || true)"
      if [ -n "$token" ]; then
        mkdir -p "${config.xdg.configHome}/nix"
        conf="${config.xdg.configHome}/nix/nix.conf"
        tmp="$(mktemp)"
        if [ -f "$conf" ]; then
          # remove any existing github access-tokens line to avoid duplicates
          grep -v '^access-tokens = github\.com=' "$conf" > "$tmp" || true
        fi
        echo "access-tokens = github.com=$token" >> "$tmp"
        install -m 0644 "$tmp" "$conf"
        rm -f "$tmp"
      fi
    '';
  };
}
