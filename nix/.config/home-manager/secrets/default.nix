{config, ...}: {
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    defaultSopsFile = ./all.yaml;
    secrets = {
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
    };
  };
}
