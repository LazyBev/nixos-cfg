{ pkgs, ... }: {
  systemd.user.services.ribbon = {
    enable = true;
    description = "ribbon — Wayland status bar";
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.ribbon}/bin/ribbon";
      Restart = "on-failure";
      RestartSec = "2";
    };
  };
}
