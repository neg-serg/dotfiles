{
  config,
  lib,
  pkgs,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; lib.mkIf config.features.media.audio.mpd.enable {
  home.packages = with pkgs; [
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
    mpdas = {
      Unit = {
        Description = "mpdas last.fm scrobbler";
        After = ["network.target" "sound.target"];
      };
      Service = {
        ExecStart = "${pkgs.mpdas}/bin/mpdas -c ${config.sops.secrets.mpdas_negrc.path}";
        Restart = "on-failure";
        RestartSec = "10";
      };
      Install = {WantedBy = ["default.target"];};
    };
  };
}
