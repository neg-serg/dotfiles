{
  config,
  lib,
  pkgs,
  ...
}:
  lib.mkIf config.features.media.audio.mpd.enable {
    home.packages = with pkgs; config.lib.neg.pkgsList [
      rmpc # alternative tui client with album cover
    ];

    services.mpd = {
      enable = false;
      dataDir = "${config.home.homeDirectory}/.config/mpd";
      musicDirectory = "${config.home.homeDirectory}/music";
    };

    services.mpdris2 = {
      enable = true;
      mpd.host = "localhost";
      mpd.port = 6600;
    };

    systemd.user.services = {
      mpdas =
        lib.recursiveUpdate {
          Unit.Description = "mpdas last.fm scrobbler";
          Service = {
            ExecStart = "${pkgs.mpdas}/bin/mpdas -c ${config.sops.secrets.mpdas_negrc.path}";
            Restart = "on-failure";
            RestartSec = "10";
          };
        } (config.lib.neg.systemdUser.mkUnitFromPresets {
          presets = ["net" "defaultWanted"];
          after = ["sound.target"]; # keep explicit sound dependency
        });
    };
  }
