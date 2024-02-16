{ pkgs, config, ... }: {
  home.packages = with pkgs; [
      ape # monkey audio codec
      audiowaveform # shows soundwaveform
      cdparanoia # cdrip / cdrecord
      cider # apple music player
      easytag # use this for tags
      id3v2 # id3v2 edit
      jamesdsp # pipewire dsp
      media-player-info # repository of data files describing media player capabilities
      mediainfo # tag information about video or audio
      mpc-cli # mpd client
      ncmpcpp # curses mpd client
      ncpamixer # cli-pavucontrol
      nicotine-plus # download music via soulseek
      picard # autotags
      playerctl # media controller for everything
      sonic-visualiser # audio analyzer
      tauon # fancy standalone music player
      unflac # split2flac alternative

      dr14_tmeter # compute the DR14 of a given audio file according to the procedure from Pleasurize Music Foundation
      ffmpeg-full
      ffmpegthumbnailer # thumbnail for video
      haruna # a nicer, better front end for mpv
      mpvc # CLI controller for mpv
      mpvScripts.mpris # playerctl support for mpv
      mpv # video player
      screenkey # screencast tool to display your keys inspired by Screenflick
      simplescreenrecorder # screen recorder
      sox # audio processing
      streamlink  # CLI for extracting streams from websites
      termplay # play video in terminal
  ];

  systemd.user.services = {
      playerctld = {
          Unit = {
              Description = "Keep track of media player activity";
              After = ["network.target" "sound.target"];
          };

          Service = {
              Type = "forking";
              ExecStart = "${pkgs.playerctl}/bin/playerctld daemon";
              RestartSec = "3";
              StartLimitBurst = "0";
          };
          Install = { WantedBy = ["default.target"]; };
      };

      mpdas = {
          Unit = {
              Description = "mpdas last.fm scrobbler";
              After = ["network.target" "sound.target" "mpd.service"];
              Requires = "mpd.service";
          };
          Service = {
              ExecStart = "${pkgs.mpdas}/bin/mpdas -c ${config.sops.secrets.mpdas_negrc.path}";
              Restart = "on-failure";
              RestartSec = "10";
          };
          Install = { WantedBy = ["default.target"]; };
      };

      cover-notify = {
          Unit = {
              Description = "Music track notification with cover";
              After = ["network.target" "sound.target" "playerctld.service" "mpd.service" "mpDris.service"];
              BindsTo = "mpDris.service";
              StartLimitIntervalSec = "0";
          };
          Service = {
              ExecStart = "${pkgs.cached-nix-shell}/bin/cached-nix-shell -p 'python3.withPackages (p: [p.pygobject3 p.systemd])' -p gobject-introspection -p playerctl --run %h/bin/track-notification-daemon";
              Restart = "always";
              RestartSec = "3";
          };
      };

      mpDris = {
          Unit = {
              Description = "mpDris2 - Music Player Daemon D-Bus bridge";
              After = ["playerctld.service" "network.target" "sound.target" "mpd.service"];
              PartOf = ["mpd.socket" "mpd.service"];
          };
          Service = {
              Type = "simple";
              Restart = "on-failure";
              ExecStart = "${pkgs.writeShellScriptBin "delay-mpdris2" "${pkgs.coreutils}/bin/sleep 1 && ${pkgs.mpdris2}/bin/mpDris2"}/bin/delay-mpdris2";
          };
          Install = { WantedBy = ["default.target"]; };
      };

      mpd = {
          Unit = {
              Description = "Music Player Daemon";
              Documentation = "man:mpd(1) man:mpd.conf(5)";
              After = ["network.target" "sound.target"];
              ConditionPathExists = "${pkgs.mpd}/bin/mpd";
          };
          Service = {
              Type = "notify";
              ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon";
              WatchdogSec = 120;
              LimitRTPRIO = "40"; # allow MPD to use real-time priority 40
              LimitRTTIME = "infinity";
              LimitMEMLOCK = "64M"; # for io_uring
              ProtectSystem = "yes"; # disallow writing to /usr, /bin, /sbin, ...
              NoNewPrivileges = "yes";
              ProtectKernelTunables = "yes";
              ProtectControlGroups = "yes";
              # AF_NETLINK is required by libsmbclient, or it will exit() .. *sigh*
              RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX" "AF_NETLINK"];
              RestrictNamespaces = "yes";
              Restart = "on-failure";
              RestartSec = "5";
          };
          Install = { WantedBy = ["default.target"]; };
      };
  };

}
