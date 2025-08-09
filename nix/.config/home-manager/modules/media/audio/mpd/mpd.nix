{
  config,
  lib,
  pkgs,
  ...
}:
with {
  l = config.lib.file.mkOutOfStoreSymlink;
  dots = "${config.home.homeDirectory}/.dotfiles";
  rmpc_git = pkgs.callPackage ../../../../packages/rmpc {};
}; {
  home.packages = with pkgs; [
    inory # alternative cli mpd client
    mpc-cli # mpd client
    rmpc_git # alternative tui client with album cover
  ];
  services.mpd = {
    enable = true;
    dataDir = "${config.home.homeDirectory}/.config/mpd";
    musicDirectory = "${config.home.homeDirectory}/music";
    network.startWhenNeeded = true;
    extraConfig = ''
      log_file "/dev/null"
      max_output_buffer_size "131072"
      max_connections "100"
      connection_timeout "864000"
      restore_paused "yes"
      save_absolute_paths_in_playlists "yes"
      #metadata_to_use "artist,album,title,track,name,genre,date"
      follow_inside_symlinks "yes"
      replaygain "off"
      auto_update "no"
      mixer_type "software"

      input_cache {
          size "1 GB"
      }

      audio_output {
          type "alsa"
          name "RME ADI-2/4 PRO SE"
          device "hw:CARD=SE53011083"
          auto_resample "no"
          auto_format "no"
          auto_channels "no"
          replay_gain_handler "none"
          dsd_native "yes"
          dop "no"
          tags "yes"
      }

      audio_output {
          type "pipewire"
          name "PipeWire"
          dsd "yes"
      }
    '';
  };

  services.mpdris2 = {
    enable = true;
    mpd.host = "127.0.0.1";
    mpd.port = 6600;
  };

  systemd.user.services = {
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
      Install = {WantedBy = ["default.target"];};
    };

    cover-notify = {
      Unit = {
        Description = "Music track notification with cover";
        After = ["mpd.service"];
        StartLimitIntervalSec = "1";
        BindsTo = ["mpd.service"];
      };
      Service = {
        ExecStart = lib.strings.concatStringsSep " " [
          "${pkgs.cached-nix-shell}/bin/cached-nix-shell "
          "-p 'python3.withPackages (p: [p.pygobject3 p.systemd p.dbus-python])' "
          "-p gobject-introspection"
          "-p mpc-cli"
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
