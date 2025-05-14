{
  pkgs,
  ...
}:
{
  systemd.user.startServices = true;
  systemd.user.services = {
    openrgb = {
      Unit = {
        Description = "OpenRGB Configuration utility for RGB lights supporting motherboards, RAM, & peripherals";
        After = ["dbus.socket"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.openrgb}/bin/openrgb --server -p neg.orp";
        RestartSec = "30";
        StartLimitBurst = "8";
      };
      Install = {WantedBy = ["default.target"];};
    };

    shot-optimizer = {
      Unit = {
        Description = "Optimize screenshots";
        After = ["sockets.target"];
      };
      Service = {
        ExecStart = "%h/bin/shot-optimizer";
        WorkingDirectory = "%h/pic/shots";
        PassEnvironment = "HOME";
        Restart = "on-failure";
        RestartSec = "1";
        StartLimitBurst = "0";
      };
      Install = {WantedBy = ["default.target"];};
    };

    pic-dirs = {
      Unit = {
        Description = "Pic dirs notification";
        After = ["sockets.target"];
        StartLimitIntervalSec = "0";
      };
      Service = {
        ExecStart = "/bin/sh -lc '%h/bin/pic-dirs-list'";
        PassEnvironment = ["XDG_PICTURES_DIR" "XDG_DATA_HOME"];
        Restart = "on-failure";
        RestartSec = "1";
      };
      Install = {WantedBy = ["default.target"];};
    };
 };
}
