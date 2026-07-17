{ config, lib, pkgs, ... }: {
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.networkmanager.wifi.backend = "iwd";
  networking.hostName = config.vars.hostname;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.firewall.enable = true;
  networking.firewall.logRefusedConnections = false;
  networking.firewall.allowedTCPPorts = [ 8087 ];

  networking.wireless.iwd.enable = true;
  networking.wireless.iwd.settings = {
    Settings = {
      AutoConnect = true;
    };
    Network = {
      EnableIPv6 = true;
    };
  };

  boot.kernelModules = [ "tcp_bbr" "sch_cake" ];
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 uapsd_disable=1
    options iwlmvm power_scheme=1
  '';
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_rmem" = "4096 87380 33554432";
    "net.ipv4.tcp_wmem" = "4096 65536 33554432";
    "net.ipv4.tcp_slow_start_after_idle" = "0";
    "net.ipv4.tcp_notsent_lowat" = "131072";
    "net.ipv4.tcp_fastopen" = "3";
    "net.ipv4.tcp_mtu_probing" = "1";
    "net.core.rmem_max" = 134217728;
    "net.core.wmem_max" = 134217728;
    "net.ipv4.udp_rmem_min" = "16384";
    "net.ipv4.udp_wmem_min" = "16384";
    "net.core.busy_read" = "50";
    "net.core.busy_poll" = "50";
  };

  services.resolved.enable = true;
  services.resolved.settings.Resolve.DNSSEC = true;
  services.resolved.settings.Resolve.FallbackDNS = "1.1.1.1 1.0.0.1";
}
