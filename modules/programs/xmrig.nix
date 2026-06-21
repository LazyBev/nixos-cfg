{ config, lib, pkgs, ... }: {
  environment.etc."xmrig/config.json".source = ../../configs/xmrig/config.json;

  systemd.services.xmrig = {
    description = "Monero miner";
    serviceConfig = {
      ExecStart = "${pkgs.xmrig}/bin/xmrig --config=/etc/xmrig/config.json";
      Restart = "on-failure";
    };
  };

  programs.fish.shellAliases = lib.mkIf config.virtualisation.docker.enable {
    xmrig-start = "doas systemctl start xmrig";
    xmrig-stop = "doas systemctl stop xmrig";
    xmrig-logs = "doas journalctl -fu xmrig";
  };
}
