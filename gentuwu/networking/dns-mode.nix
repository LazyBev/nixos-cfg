{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce;
in
{
  # ─── dns-mode: AdGuardHome | validating chain | plain | tor ─────────────
  # Every daemon binds its own loopback port so the stacks can coexist; the
  # active mode just decides which endpoint systemd-resolved points at.
  #
  #   127.0.0.1:53    AdGuardHome frontend (DoH upstreams)      [filtered]
  #   127.0.0.1:5353  dnsmasq (stateless, cache-size=0)          [validated/plain/tor]
  #   127.0.0.1:5354  unbound (DNSSEC validator)                 [validated]
  #   127.0.0.1:5355  dnscrypt-proxy (encrypted upstream)        [validated]
  #   127.0.0.1:5356  tor DNSPort (anonymized)                   [tor]
  #
  # Boot default = filtered (AdGuardHome owns :53, same as before). Switching
  # is done by `dns-mode <filtered|validated|plain|tor>`.

  # ─── filtered mode: frontend managed by services/adguardhome (DoH) ──────
  # AdGuardHome owns 127.0.0.1:53 (see services/adguardhome.nix). The other
  # stacks bind their own ports below so all modes coexist until switched.

  # ─── validated / plain / tor frontend: dnsmasq ─────────────────────────
  # Stateless forwarding resolver (`cache-size=0 no-negcache`).
  # Upstreams are injected at runtime via /run/dnsmode/servers so one binary
  # serves all three chain modes; `systemctl reload dnsmasq` re-reads it.
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      port = 5353;
      bind-interfaces = true;
      listen-address = [ "127.0.0.1" ];
      no-resolv = true;
      no-hosts = true;
      cache-size = 0;
      no-negcache = true;
      local-service = true;
      servers-file = "/run/dnsmode/servers";
    };
  };

  systemd.services.dnsmasq = {
    wantedBy = mkForce [ ];
    preStart = ''
      mkdir -p /run/dnsmode
    '';
  };

  systemd.tmpfiles.rules = [ "d /run/dnsmode 0755 root root -" ];

  # ─── DNSSEC validator: unbound (forwards to dnscrypt-proxy) ──────────────
  # `module-config` is intentionally NOT set: it defaults to "validator iterator"
  # (the whole point of this hop), and the NixOS settings renderer writes the
  # string unquoted, which 1.26.0's parser rejects (`unknown keyword 'iterator'`).
  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "127.0.0.1" ];
        port = 5354;
        do-not-query-localhost = false;
        access-control = [ "127.0.0.0/8 allow" ];
        hide-identity = true;
        hide-version = true;
      };
      forward-zone = [
        {
          name = ".";
          forward-addr = [ "127.0.0.1@5355" ];
        }
      ];
    };
  };

  systemd.services.unbound = {
    wantedBy = mkForce [ ];
  };

  # ─── Encrypted upstream: dnscrypt-proxy ───────────────────────────────────
  # Listens on 127.0.0.1:5355; upstreams come from the public-resolvers list.
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:5355" ];
      server_names = [
        "cloudflare"
        "quad9-dnscrypt-ip4-nofilter-pri"
      ];
      require_dnssec = true;
      cache = false;
      log_level = 0;
      sources.public-resolvers = {
        urls = [ "https://download.dnscrypt.info/resolvers-list/v2/public-resolvers.md" ];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      netprobe_timeout = 60;
      fallback_resolvers = [ "1.1.1.1:53" ];
    };
  };

  systemd.services.dnscrypt-proxy = {
    wantedBy = mkForce [ ];
    after = [ "network-online.target" ];
  };

  # ─── tor mode: DNSPort ─────────────────────────────────────────────────
  # tor DNSPort answers on 127.0.0.1:5356; dnsmasq forwards there. tor stays
  # stopped at boot (arti holds host SOCKS); `dns-mode tor` starts it.
  services.tor.settings.DNSPort = {
    addr = "127.0.0.1";
    port = 5356;
  };

  # ─── dns-mode control script (root) ──────────────────────────────────────
  # The fish wrapper `dns-mode` calls this via doas. It rewrites the dnsmasq
  # upstream file, toggles the right daemons, and repoints systemd-resolved
  # at the active frontend (resolved accepts `IP#port`).
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "dns-mode-ctl" ''
      #!/bin/sh
      mode="$1"
      state=/run/dnsmode/servers
      mkdir -p /run/dnsmode

      write_upstream() {
        : > "$state"
        for s in "$@"; do echo "server=$s" >> "$state"; done
        chmod 644 "$state"
      }

      # systemd-resolved: set DNS for every real link to the active frontend,
      # with plain public resolvers as a trailing fallback so resolved can
      # step past a dead local frontend per query.
      fallback_resolvers="1.1.1.1 1.0.0.1"
      linkdns() {
        for iface in $(resolvectl 2>/dev/null | sed -n 's/^Link [0-9]* (\([^)]*\)):*$/\1/p'); do
          case "$iface" in lo|docker*) continue;; esac
          resolvectl dns "$iface" "$@" $fallback_resolvers 2>/dev/null
        done
      }

      case "$mode" in
        filtered)
          systemctl stop dnsmasq unbound dnscrypt-proxy tor 2>/dev/null
          systemctl restart adguardhome 2>/dev/null
          systemctl restart arti 2>/dev/null
          linkdns 127.0.0.1
          echo filtered > /run/dnsmode/mode
          ;;
        validated)
          systemctl stop tor 2>/dev/null
          systemctl restart arti 2>/dev/null
          systemctl start dnscrypt-proxy unbound 2>/dev/null
          write_upstream "127.0.0.1#5354"
          systemctl restart dnsmasq
          linkdns "127.0.0.1#5353"
          echo validated > /run/dnsmode/mode
          ;;
        plain)
          systemctl stop unbound dnscrypt-proxy tor 2>/dev/null
          systemctl restart arti 2>/dev/null
          write_upstream "1.1.1.1" "9.9.9.9"
          systemctl restart dnsmasq
          linkdns "127.0.0.1#5353"
          echo plain > /run/dnsmode/mode
          ;;
        tor)
          systemctl stop unbound dnscrypt-proxy 2>/dev/null
          systemctl stop arti 2>/dev/null
          systemctl start tor 2>/dev/null
          write_upstream "127.0.0.1#5356"
          systemctl restart dnsmasq
          linkdns "127.0.0.1#5353"
          echo tor > /run/dnsmode/mode
          ;;
        status)
          echo "── DNS mode status ──"
          echo "linkdns:"
          resolvectl 2>/dev/null | sed -n 's/^Link [0-9]* (\([^)]*\)):*$/\1/p' | while read -r f; do
            echo "  $f: $(resolvectl dns "$f" 2>/dev/null | head -1)"
          done
          echo "upstreams: $(cat "$state" 2>/dev/null || echo '(none)')"
          echo "daemons:"
          for s in adguardhome dnsmasq unbound dnscrypt-proxy tor arti; do
            printf "  %-16s %s\n" "$s" "$(systemctl is-active "$s" 2>/dev/null)"
          done
          ;;
        *)
          echo "usage: dns-mode <filtered|validated|plain|tor|status>" >&2
          exit 1
          ;;
      esac
    '')
  ];
}
