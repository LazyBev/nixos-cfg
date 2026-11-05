{ config, pkgs, lib, ... }:
{
  services.dnsmasq = {
    enable = true;
    settings = {
      port = 5353;
      cache-size = 0;
      no-resolv = true;
      no-poll = true;
      bind-interfaces = true;
      listen-address = "127.0.0.1";
      domain-needed = false;
      bogus-priv = false;
      strict-order = true;
    };
  };

  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" ];
        port = 5354;
        do-tcp = true;
        do-udp = true;
        hide-identity = true;
        hide-version = true;
        qname-minimisation = true;
        minimal-responses = true;
        prefetch = true;
        use-caps-for-id = true;
        harden-glue = true;
        harden-dnssec-stripped = true;
        harden-below-nxdomain = true;
        harden-referral-path = true;
        harden-algo-downgrade = true;
        harden-large-queries = true;
        val-permissive-mode = false;
        val-clean-additional = true;
        do-not-query-localhost = false;
      };
      forward-zone = [
        {
          name = ".";
          forward-addr = "127.0.0.1@5355";
        }
      ];
    };
  };

  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = ["127.0.0.1:5355"];
      server_names = ["quad9-dnscrypt-ip4-filter-pri"];
      ipv4_servers = true;
      ipv6_servers = false;
      dnscrypt_servers = true;
      doh_servers = false;
      odoh_servers = false;
      require_dnssec = true;
      require_nolog = true;
      require_nofilter = false;
      force_tcp = false;
      timeout = 2500;
      keepalive = 30;
      lb_strategy = "p2";
      lb_estimator = true;
      cache = false;
      cache_size = 4096;
      cache_min_ttl = 2400;
      cache_max_ttl = 86400;
      blocked_names.blocked_names_file = "blocked-names.txt";
      blocked_ips.blocked_ips_file = "blocked-ips.txt";
      allowed_names.allowed_names_file = "allowed-names.txt";
      allowed_ips.allowed_ips_file = "allowed-ips.txt";
      sources.public-resolvers = {
        urls = ["https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        refresh_delay = 72;
      };
    };
  };

  systemd.services.unbound = {
    after = [ "dnscrypt-proxy.service" ];
    requires = [ "dnscrypt-proxy.service" ];
  };

  systemd.services.dnscrypt-proxy = {
    after = [ "network.target" ];
  };

  environment.systemPackages = [
    (pkgs.writeShellScriptBin "route" ''
      #!/bin/sh
      mode="''${1:?usage: route <plain|secure|tor|status>}"
      state=/run/routemode/servers
      modefile=/run/routemode/mode
      NFT=${pkgs.nftables}/bin/nft
      SET="inet dnsguard allowed_resolvers_ip4"
      mkdir -p /run/routemode

      write_upstream() {
        : > "$state"
        for s in "$@"; do echo "server=$s" >> "$state"; done
        chmod 644 "$state"
      }

      fw_close() {
        $NFT flush set $SET 2>/dev/null || true
      }
      fw_allow_plain() {
        fw_close
        $NFT add element $SET '{ 1.1.1.1, 1.0.0.1, 9.9.9.9, 9.9.9.10 }' 2>/dev/null || true
      }
      fw_allow_bootstrap() {
        fw_close
        $NFT add element $SET '{ 1.1.1.1 timeout 5m }' 2>/dev/null || true
      }

      ensure_dnsguard() {
        $NFT list table inet dnsguard >/dev/null 2>&1 || true
      }

      begin() {
        ensure_dnsguard
        fw_close
      }

      need_active() {
        sleep 1
        if ! systemctl is-active --quiet "$1"; then
          echo "route: $1 failed to start" >&2
          fw_close
          echo "failed ($mode)" > "$modefile"
          exit 1
        fi
      }

      case "$mode" in
        plain)
          begin
          systemctl stop tor-hardening tor 2>/dev/null || true
          write_upstream "1.1.1.1" "9.9.9.9"
          systemctl restart dnsmasq
          need_active dnsmasq
          systemctl stop unbound dnscrypt-proxy 2>/dev/null || true
          systemctl start adguardhome 2>/dev/null || true
          fw_allow_plain
          echo plain > "$modefile"
          echo "route: plain"
          ;;
        secure)
          begin
          systemctl stop tor-hardening tor 2>/dev/null || true
          write_upstream "127.0.0.1#5354"
          systemctl restart dnsmasq
          need_active dnsmasq
          systemctl start adguardhome 2>/dev/null || true
          fw_allow_bootstrap
          systemctl start unbound 2>/dev/null || true
          systemctl restart dnscrypt-proxy 2>/dev/null || true
          need_active dnscrypt-proxy
          need_active unbound
          echo secure > "$modefile"
          echo "route: secure"
          ;;
        tor)
          begin
          write_upstream "127.0.0.1#5356"
          systemctl restart dnsmasq
          need_active dnsmasq
          systemctl stop unbound dnscrypt-proxy 2>/dev/null || true
          systemctl start adguardhome 2>/dev/null || true
          systemctl start tor 2>/dev/null || true
          need_active tor
          systemctl start tor-hardening 2>/dev/null || true
          need_active tor-hardening
          echo tor > "$modefile"
          echo "route: tor (all TCP via Tor)"
          ;;
        status)
          echo "route: $(cat "$modefile" 2>/dev/null || echo unknown)"
          echo "upstreams: $(cat "$state" 2>/dev/null | tr '\n' ' ')"
          echo "nft: $($NFT list set $SET 2>/dev/null | grep -o '{[^}]*}' | head -1)"
          for s in adguardhome dnsmasq unbound dnscrypt-proxy tor tor-hardening; do
            printf "  %-16s %s\n" "$s" "$(systemctl is-active "$s" 2>/dev/null)"
          done
          ;;
        *)
          echo "usage: route <plain|secure|tor|status>" >&2
          exit 1
          ;;
      esac
    '')
  ];

  systemd.services.routemode-boot = {
    description = "Apply tor routing at boot";
    after = [ "network-online.target" "dnsmasq.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      /run/current-system/sw/bin/route tor || true
    '';
  };
}
