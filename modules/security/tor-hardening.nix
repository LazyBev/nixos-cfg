{ config, lib, pkgs, ... }: let
  hasTransparentProxy = config.services.tor.enable && (config.services.tor.settings.TransPort or null) != null;
in lib.mkIf hasTransparentProxy {
  systemd.services.tor-hardening = {
    description = "Tor transparent proxy: redirect all TCP through Tor, DNS leak prevention";
    after = [ "tor.service" "network.target" ];
    wants = [ "tor.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.iptables ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      # NAT table - transparent proxy
      iptables -t nat -N TOR_PROXY 2>/dev/null || iptables -t nat -F TOR_PROXY
      iptables -t nat -A TOR_PROXY -o lo -j RETURN
      iptables -t nat -A TOR_PROXY -p tcp --dport 9040 -j RETURN
      iptables -t nat -A TOR_PROXY -p tcp --dport 9050 -j RETURN
      iptables -t nat -A TOR_PROXY -p tcp --dport 9051 -j RETURN
      iptables -t nat -A TOR_PROXY -p tcp -j REDIRECT --to-ports 9040
      iptables -t nat -A OUTPUT -j TOR_PROXY

      # DNS leak prevention - redirect all DNS to Tor's DNSPort
      iptables -t nat -N TOR_DNS 2>/dev/null || iptables -t nat -F TOR_DNS
      iptables -t nat -A TOR_DNS -o lo -j RETURN
      iptables -t nat -A TOR_DNS -p udp --dport 5353 -j RETURN
      iptables -t nat -A TOR_DNS -p udp --dport 53 -j REDIRECT --to-ports 5353
      iptables -t nat -A OUTPUT -j TOR_DNS

      # Filter table - block non-Tor outbound
      iptables -N TOR_OUT 2>/dev/null || iptables -F TOR_OUT
      iptables -A TOR_OUT -o lo -j ACCEPT
      iptables -A TOR_OUT -p tcp --dport 9040 -j ACCEPT
      iptables -A TOR_OUT -p tcp --dport 9050 -j ACCEPT
      iptables -A TOR_OUT -p tcp --dport 9051 -j ACCEPT
      iptables -A TOR_OUT -p udp --dport 5353 -j ACCEPT
      iptables -A TOR_OUT -p udp --dport 123 -j ACCEPT
      iptables -A TOR_OUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      iptables -A TOR_OUT -j DROP
      iptables -A OUTPUT -j TOR_OUT
    '';
    preStop = ''
      iptables -t nat -D OUTPUT -j TOR_PROXY 2>/dev/null || true
      iptables -t nat -F TOR_PROXY 2>/dev/null || true
      iptables -t nat -X TOR_PROXY 2>/dev/null || true
      iptables -t nat -D OUTPUT -j TOR_DNS 2>/dev/null || true
      iptables -t nat -F TOR_DNS 2>/dev/null || true
      iptables -t nat -X TOR_DNS 2>/dev/null || true
      iptables -D OUTPUT -j TOR_OUT 2>/dev/null || true
      iptables -F TOR_OUT 2>/dev/null || true
      iptables -X TOR_OUT 2>/dev/null || true
    '';
  };
}
