{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
  mkIf config.features.mail.enable {
    home.packages = with pkgs; [
      vdirsyncer # add vdirsyncer binary for sync and initialization
    ];

    # Ensure local storage directories exist
    home.activation.vdirsyncerDirs = config.lib.neg.mkEnsureDirsAfterWrite [
      "$HOME/.config/vdirsyncer/calendars"
      "$HOME/.config/vdirsyncer/contacts"
    ];

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
    systemd.user.services.vdirsyncer = lib.recursiveUpdate {
      Unit.Description = "Vdirsyncer synchronization service";
      Service = {
        Type = "oneshot";
        ExecStartPre = "${pkgs.vdirsyncer}/bin/vdirsyncer metasync";
        ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
      };
    } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["netOnline"];});

    systemd.user.timers.vdirsyncer = lib.recursiveUpdate {
      Unit.Description = "Vdirsyncer synchronization timer";
      Timer = {
        OnBootSec = "2m";
        OnUnitActiveSec = "5m";
        Unit = "vdirsyncer.service";
      };
    } (config.lib.neg.systemdUser.mkUnitFromPresets {presets = ["timers"];});
  }
