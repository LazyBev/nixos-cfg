{ pkgs, ... }:
let
  nft = "${pkgs.nftables}/bin/nft";
in
{
  services = {
    networkmanager.enable = true;
    dhcpcd.enable = true;
    iwd = {
      enable = true;
      settings = {
        Settings.AutoConnect = true;
        Network.EnableIPv6 = false;
      };
    };
  };

  boot.kernelModules = [
    "tcp_bbr"
    "sch_cake"
  ];

  programs.modprobe.extraConfig = ''
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

  finit.tasks.dnsguard = {
    description = "DNS egress guard (nftables table)";
    runlevels = "S";
    script = ''
      ${nft} delete table inet dnsguard 2>/dev/null || true
      ${nft} -f ${pkgs.writeText "dnsguard.nft" ''
        table inet dnsguard {
          set allowed_resolvers {
            type ipv4_addr
            elements = { 1.1.1.1, 1.0.0.1, 9.9.9.9, 9.9.9.10 }
          }

          chain output {
            type filter hook output priority 0; policy accept;
            oifname "lo" accept
            meta l4proto { udp, tcp } th dport 53 ip daddr @allowed_resolvers accept
            meta l4proto { udp, tcp, icmp } th dport 53 counter drop
          }
        }
      ''}
    '';
  };

  finit.tasks.ipv6-block = {
    description = "Block IPv6 output traffic";
    runlevels = "2345";
    script = ''
      ${nft} delete table inet ipv6block 2>/dev/null || true
      ${nft} -f ${pkgs.writeText "ipv6-block.nft" ''
        table inet ipv6block {
          chain output {
            type filter hook output priority -5; policy accept;
            oifname "lo" accept
            meta nfproto ipv6 drop
          }
        }
      ''}
    '';
  };
}
