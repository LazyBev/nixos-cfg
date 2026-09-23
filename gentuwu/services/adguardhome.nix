{
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    mutableSettings = true;
    settings = {
      schema_version = 22;
      dns = {
        port = 53;
        # 10.254.0.1 = host end of the browsernet netVM veth
        # (networking/netvms.nix); binds the sandboxed browsers onto the same
        # filtered chain so their DNS no longer leaks to a plaintext 1.1.1.1.
        bind_hosts = [
          "127.0.0.1"
          "10.254.0.1"
        ];
        upstream_dns = [
          "https://dns.adguard-dns.com/dns-query"
          "https://dns.quad9.net/dns-query"
        ];
        upstream_dns_file = "";
        bootstrap_dns = [
          "94.140.14.14"
          "9.9.9.9"
        ];
        fallback_dns = [ "https://dns.adguard-dns.com/dns-query" ];
        # ── filtering/hardening (mutableSettings=true means these only seed a
        # ── FRESH adguard data dir; on the live box paste the filter URLs into
        # ── the web UI instead unless you want to wipe ~/.local/share/adguardhome)
        filtering_enabled = true;
        dnssec = true;
        disable_ipv6 = true;
        blocking_ipv4 = "0.0.0.0";
        blocking_ipv6 = "::";
        upstream_mode = "load_balance";
      };
      # Curated blocklists — drop large/ad-heavy lists if you rely on it too
      # much: the HaGeZi PRO list is aggressive (also kills newsletter links).
      filters = [
        {
          id = 1;
          enabled = true;
          name = "OISD full (ads + trackers)";
          url = "https://big.oisd.nl/domains";
        }
        {
          id = 2;
          enabled = true;
          name = "1Hosts (Xtra)";
          url = "https://raw.githubusercontent.com/badmojr/1Hosts/master/Xtra/hosts.txt";
        }
        {
          id = 3;
          enabled = true;
          name = "AdGuard DNS filter";
          url = "https://adguardteam.github.io/AdGuardSDNSFilter/Filters/filter.txt";
        }
        {
          id = 4;
          enabled = true;
          name = "HaGeZi PRO (aggressive)";
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
        }
      ];
    };
  };

  # AdGuardHome must bind 10.254.0.1 only after the browsernet domain has
  # created it, otherwise its :53 listener fails to come up.
  systemd.services.adguardhome = {
    after = [ "netvm-browsernet.service" ];
  };
}
