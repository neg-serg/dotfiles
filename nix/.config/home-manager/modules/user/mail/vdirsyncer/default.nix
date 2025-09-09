{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.mail {
    home.packages = with pkgs; [
      vdirsyncer # add vdirsyncer binary for sync and initialization
    ];

    # Ensure local storage directories exist
    home.activation.vdirsyncerDirs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.config/vdirsyncer/calendars" "$HOME/.config/vdirsyncer/contacts"
    '';

    # Provide a starter config. Fill in URL/username/password below.
    xdg.configFile."vdirsyncer/config".text = ''
      [general]
      status_path = "${config.xdg.stateHome or "$HOME/.local/state"}/vdirsyncer"

      # Calendars pair (filesystem <-> CalDAV)
      [pair calendars]
      a = "calendars_local"
      b = "calendars_remote"
      collections = ["from b"]
      conflict_resolution = "b wins"
      metadata = ["color", "displayname"]

      [storage calendars_local]
      type = "filesystem"
      path = "${config.home.homeDirectory}/.config/vdirsyncer/calendars"
      fileext = ".ics"

      [storage calendars_remote]
      type = "caldav"
      # TODO: Replace with your CalDAV base URL (e.g., Nextcloud/Fastmail)
      # Example (Nextcloud): https://cloud.example.com/remote.php/dav/calendars/USERNAME/
      url = "https://REPLACE-ME-CALDAV-BASE/"
      username = "REPLACE-ME-USER"
      password = "REPLACE-ME-PASSWORD"
      verify = true

      # Contacts pair (filesystem <-> CardDAV)
      [pair contacts]
      a = "contacts_local"
      b = "contacts_remote"
      collections = ["from b"]
      conflict_resolution = "b wins"

      [storage contacts_local]
      type = "filesystem"
      path = "${config.home.homeDirectory}/.config/vdirsyncer/contacts"
      fileext = ".vcf"

      [storage contacts_remote]
      type = "carddav"
      # TODO: Replace with your CardDAV base URL (e.g., Nextcloud/Fastmail)
      # Example (Nextcloud): https://cloud.example.com/remote.php/dav/addressbooks/users/USERNAME/
      url = "https://REPLACE-ME-CARDDAV-BASE/"
      username = "REPLACE-ME-USER"
      password = "REPLACE-ME-PASSWORD"
      verify = true
    '';
    systemd.user.services.vdirsyncer = {
      Unit = {
        Description = "Vdirsyncer synchronization service";
        After = [
          "network-online.target" # require working network
        ];
        Wants = [
          "network-online.target" # pull in network-online
        ];
      };
      Service = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.vdirsyncer}/bin/vdirsyncer metasync";
        ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
      };
    };

    systemd.user.timers.vdirsyncer = {
      Unit = {Description = "Vdirsyncer synchronization timer";};
      Timer = {
        OnBootSec = "2m";
        OnUnitActiveSec = "5m";
        Unit = "vdirsyncer.service";
      };
      Install = {
        WantedBy = [
          "timers.target" # hook into user timers
        ];
      };
    };
  }
