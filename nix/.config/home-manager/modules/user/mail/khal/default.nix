{...}: {
  programs.khal.enable = true;
  programs.khal.locale = {
    local_timezone = "Europe/Moscow";
    timeformat = "%H:%M";
    dateformat = "%d/%m/%Y";
    longdateformat = "%d/%m/%Y";
    datetimeformat = "%d/%m/%Y %H:%M";
    longdatetimeformat = "%d/%m/%Y %H:%M";
    firstweekday = 0;
  };

  programs.khal.settings = {
    default = {
      default_calendar = "calendar";
      highlight_event_days = true;
      timedelta = "30d";
    };
  };

  accounts = {
    contact.basePath = ".config/vdirsyncer/contacts";
    calendar.basePath = ".config/vdirsyncer/calendars";

    calendar.accounts."calendar" = {
      khal.enable = true;
    };

    calendar.accounts."contacts" = {
      khal.enable = true;
    };
  };
}
