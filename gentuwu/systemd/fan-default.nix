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
    serviceConfig.ExecStartPre = "${pkgs.bash}/bin/bash -c 'for ((i = 0; i < 30; i++)); do [ -S /run/nbfc_service.socket ] && exit 0; ${pkgs.coreutils}/bin/sleep 1; done; exit 1'";
    serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.nbfc-linux}/bin/nbfc set -s ${toString config.services.nbfc.manualSpeed}'";
  };
}
