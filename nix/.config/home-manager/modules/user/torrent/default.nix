{
  pkgs,
  ...
}:
with {
  bt-migrate = pkgs.callPackage ../../packages/bt-migrate {};
  transmission = pkgs.transmission_4;
}; {
  home.packages = with pkgs; [
    bitmagnet # dht crawler
    # bt-migrate # torrent migrator
    # stig # transmission client
    rustmission # new transmission client
  ];

  systemd.user.services.transmission-daemon = {
    Unit = {
      Description = "transmission service";
      After = ["network.target"];
      ConditionPathExists = "${transmission}/bin/transmission-daemon";
    };
    Service = {
      Type = "notify";
      ExecStart = "${transmission}/bin/transmission-daemon -g %E/transmission-daemon -f --log-error";
      Restart = "on-failure";
      RestartSec = "30";
      StartLimitBurst = "8";
      ExecReload = "${pkgs.util-linux}/bin/kill -s HUP $MAINPID";
    };
    Install = {WantedBy = ["default.target"];};
  };
}
