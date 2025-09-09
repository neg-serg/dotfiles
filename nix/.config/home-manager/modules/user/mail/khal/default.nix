{
  lib,
  config,
  ...
}:
with lib;
  mkIf config.features.mail.enable {
    programs.khal = {
      enable = true;

      locale = {
        local_timezone = "Europe/Moscow";
        timeformat = "%H:%M";
        dateformat = "%d/%m/%Y";
        longdateformat = "%d/%m/%Y";
        datetimeformat = "%d/%m/%Y %H:%M";
        longdatetimeformat = "%d/%m/%Y %H:%M";
        firstweekday = 0;
      };

      settings = {
        default = {
          default_calendar = "calendar";
          highlight_event_days = true;
          timedelta = "30d";
        };
      };
    };

    accounts = {
      contact.basePath = ".config/vdirsyncer/contacts";
      calendar = {
        basePath = ".config/vdirsyncer/calendars";
        accounts = {
          "calendar" = {
            khal.enable = true;
          };
          "contacts" = {
            khal.enable = true;
          };
        };
      };
    };
  }
