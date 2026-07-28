{ config, pkgs, lib, ... }: {
  programs.niri = {
    enable = true;
    withUWSM = true;
  };
  services.gnome.gnome-keyring.enable = false;
  programs.hyprlock.enable = true;
  environment.systemPackages = [ pkgs.hypridle ];

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gtk" ];
  };

  systemd.services.fan-default = {
    description = "Set fan speed to 10%";
    after = [ "nbfc.service" ];
    wants = [ "nbfc.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.nbfc-linux}/bin/nbfc set -s 10'";
  };
}
