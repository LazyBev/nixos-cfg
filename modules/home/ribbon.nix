{ pkgs, ... }: {
  systemd.user.services.ribbon = {
    enable = true;
    description = "ribbon — Wayland status bar";
    after = [ "graphical-session.target" "pipewire.service" ];
    wants = [ "pipewire.service" ];
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.ribbon}/bin/ribbon";
      Restart = "on-failure";
      RestartSec = "2";
      Environment = "PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/run/wrappers/bin";
      PassEnvironment = "HOME";
    };
  };
}
