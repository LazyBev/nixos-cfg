{ pkgs, ... }: {
  networking.firewall = {
    enable = true;
    logRefusedConnections = false;
    allowPing = false;
    checkReversePath = "loose";
  };

  # DNS egress guard: only the loopback chain (dnsmasq/unbound/AdGuardHome on
  # 127.0.0.1) and the trusted resolver IPs below may leave on port 53. This
  # kills the classic malware exfil/DNS-tunneling channel: a compromised app
  # can't phone home over plaintext DNS, and DoH/DoT (:443/:853) to the same
  # resolvers is untouched. `plain` mode + resolved's fallbacks stay working
  # (1.1.1.1/9.9.9.9), dnscrypt upstreams (cloudflare/quad9) use :443.
  #
  # Loaded via our own oneshot, NOT networking.nftables: that module
  # blacklists the ip_tables kernel module, which Docker needs (docker NAT).
  systemd.services.dnsguard = {
    description = "DNS egress guard (nftables table)";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.nftables}/bin/nft delete table inet dnsguard 2>/dev/null || true
      ${pkgs.nftables}/bin/nft -f ${pkgs.writeText "dnsguard.nft" ''
        table inet dnsguard {
          set allowed_resolvers_ip4 {
            type ipv4_addr
            elements = { 1.1.1.1, 1.0.0.1, 9.9.9.9, 9.9.9.10 }
          }

          chain output {
            type filter hook output priority 0; policy accept;
            oifname "lo" accept
            meta l4proto udp th dport 53 ip daddr @allowed_resolvers_ip4 accept
            meta l4proto tcp th dport 53 ip daddr @allowed_resolvers_ip4 accept
            meta l4proto udp th dport 53 counter drop
            meta l4proto tcp th dport 53 counter drop
            meta l4proto icmp th dport 53 counter drop
          }
        }
      ''}
    '';
  };
}
