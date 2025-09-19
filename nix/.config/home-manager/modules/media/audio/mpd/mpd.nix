{
  config,
  lib,
  pkgs,
  ...
}:
  lib.mkIf config.features.media.audio.mpd.enable (lib.mkMerge [
    {
      home.packages = config.lib.neg.pkgsList [
        pkgs.rmpc # alternative tui client with album cover
      ];

      services.mpd = {
        enable = false;
        dataDir = "${config.xdg.stateHome}/mpd";
        musicDirectory = "${config.home.homeDirectory}/music";
      };

      services.mpdris2 = {
        enable = true;
        mpd.host = "localhost";
        mpd.port = 6600;
      };

      systemd.user.services = {
        mpdas = lib.mkMerge [
          {
            Unit = { Description = "mpdas last.fm scrobbler"; };
            Service = {
              ExecStart = "${pkgs.mpdas}/bin/mpdas -c ${config.sops.secrets.mpdas_negrc.path}";
              Restart = "on-failure";
              RestartSec = "10";
            };
          }
          (config.lib.neg.systemdUser.mkUnitFromPresets {
            presets = ["net" "defaultWanted"];
            after = ["sound.target"]; # preserve additional ordering
          })
        ];
      };
    }
    # Soft migration notice: move MPD dataDir to XDG state
    (let
      oldPath = "${config.home.homeDirectory}/.config/mpd";
      current = (config.services.mpd.dataDir or oldPath);
    in {
      warnings = lib.optional (current == oldPath)
        "MPD dataDir uses ~/.config/mpd. Consider migrating to $XDG_STATE_HOME/mpd for better XDG compliance.";
    })
  ])
