{
  config,
  lib,
  pkgs,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
}; {
  home.packages = with pkgs; [
    inori # alternative cli mpd client
    rmpc  # alternative tui client with album cover
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

    cover-notify = {
      Unit = {
        Description = "Music track notification with cover";
        StartLimitIntervalSec = "1";
      };
      Service = {
        ExecStart = lib.strings.concatStringsSep " " [
          "${pkgs.cached-nix-shell}/bin/cached-nix-shell "
          "-p 'python3.withPackages (p: [p.pygobject3 p.systemd p.dbus-python])' "
          "-p gobject-introspection"
          "-p sox"
          "-p dunst"
          "-p swaynotificationcenter"
          "-p id3lib"
          "--run %h/bin/track-notification"
        ];
        Restart = "always";
        RestartSec = "3";
      };
      Install = {WantedBy = ["default.target"];};
    };
  };
}
