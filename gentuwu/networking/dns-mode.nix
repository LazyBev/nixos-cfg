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
  # ─── dns-mode: AdGuardHome | LainOS chain | plaintext | private ──────────
  # Every daemon binds its own loopback port so the stacks can coexist; the
  # active mode just decides which endpoint systemd-resolved points at.
  #
  #   127.0.0.1:53    AdGuardHome frontend (DoH upstreams)      [adguard]
  #   127.0.0.1:5353  dnsmasq (stateless, cache-size=0)          [lainos/plaintext/private]
  #   127.0.0.1:5354  unbound (DNSSEC validator)                 [lainos]
  #   127.0.0.1:5355  dnscrypt-proxy (encrypted upstream)        [lainos]
  #   127.0.0.1:5356  tor DNSPort (private mode)                 [private]
  #
  # Boot default = adguard (AdGuardHome owns :53, same as before). Switching
  # is done by `dns-mode <adguard|lainos|plaintext|private>`.

  # ─── adguard mode: frontend managed by services/adguardhome (DoH) ───────
  # AdGuardHome owns 127.0.0.1:53 (see services/adguardhome.nix). The other
  # stacks bind their own ports below so all modes coexist until switched.

  # ─── lainos / plaintext / private frontend: dnsmasq ─────────────────────
  # Stateless forwarding resolver (mirrors LainOS `cache-size=0 no-negcache`).
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
    description = "Dnsmasq stateless DNS frontend (dns-mode)";
    preStart = ''
      mkdir -p /run/dnsmode
    '';
  };

  systemd.tmpfiles.rules = [ "d /run/dnsmode 0755 root root -" ];

  # ─── DNSSEC validator: unbound (forwards to dnscrypt-proxy) ──────────────
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
        # DNSSEC validation is the whole point of this hop.
        module-config = "validator iterator";
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
    description = "Unbound DNSSEC resolver (dns-mode lanos chain)";
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
    description = "dnscrypt-proxy encrypted DNS upstream (dns-mode)";
    after = [ "network-online.target" ];
  };

  # ─── Private mode: tor DNSPort ───────────────────────────────────────────
  # tor DNSPort answers on 127.0.0.1:5356; dnsmasq forwards there. tor stays
  # stopped at boot (topaz/arti own SOCKS); `dns-mode private` starts it.
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

      # systemd-resolved: set DNS for every real link to the active frontend.
      linkdns() {
        for iface in $(resolvectl 2>/dev/null | sed -n 's/^Link [0-9]* (\([^)]*\)):*$/\1/p'); do
          case "$iface" in lo|docker*) continue;; esac
          resolvectl dns "$iface" "$1" 2>/dev/null
        done
      }

      case "$mode" in
        adguard)
          systemctl stop dnsmasq unbound dnscrypt-proxy tor 2>/dev/null
          systemctl restart arti 2>/dev/null
          linkdns 127.0.0.1
          echo adguard > /run/dnsmode/mode
          ;;
        lainos)
          systemctl stop tor 2>/dev/null
          systemctl restart arti 2>/dev/null
          systemctl start dnscrypt-proxy unbound 2>/dev/null
          write_upstream "127.0.0.1#5354"
          systemctl restart dnsmasq
          linkdns "127.0.0.1#5353"
          echo lainos > /run/dnsmode/mode
          ;;
        plaintext)
          systemctl stop unbound dnscrypt-proxy tor 2>/dev/null
          systemctl restart arti 2>/dev/null
          write_upstream "1.1.1.1" "9.9.9.9"
          systemctl restart dnsmasq
          linkdns "127.0.0.1#5353"
          echo plaintext > /run/dnsmode/mode
          ;;
        private)
          systemctl stop unbound dnscrypt-proxy 2>/dev/null
          systemctl stop arti 2>/dev/null
          systemctl start tor 2>/dev/null
          write_upstream "127.0.0.1#5356"
          systemctl restart dnsmasq
          linkdns "127.0.0.1#5353"
          echo private > /run/dnsmode/mode
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
          echo "usage: dns-mode <adguard|lainos|plaintext|private|status>" >&2
          exit 1
          ;;
      esac
    '')
  ];
}