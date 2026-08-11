{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf config.services.nbfc.enable {
  systemd.services.fan-default = {
    description = "Apply fixed manual fan speed";
    after = [ "nbfc.service" ];
    wants = [ "nbfc.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.nbfc-linux}/bin/nbfc set -s ${toString config.services.nbfc.manualSpeed}'";
  };
}
