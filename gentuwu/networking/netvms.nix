{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mapAttrsToList mkMerge;
  ip = "${pkgs.iproute2}/bin/ip";
  nft = "${pkgs.nftables}/bin/nft";

  # ---------------------------------------------------------------------------
  # netVM: Qubes-style network domains at namespace level.
  #
  # Each domain is a tiny veth "qube network" the firejail profiles join:
  #
  #    10.254.<idx>.1  host end of the veth (runs the adguard DNS frontend)
  #    10.254.<idx>.2  sandbox end (firejail `netns <name>`)
  #
  # A per-domain nft table does the NAT (postrouting masquerade) and, more
  # importantly, enforces the domain's FORWARD policy so "internet" and "LAN"
  # are privileges, not defaults. The DENYLIST side is handled by the dnsguard
  # firewall; this is the per-app network compartment half.
  #
  # Add a domain here, then a firejail profile with `netns <newname>`,
  # `dns 10.254.<idx>.1` and you have a new isolated network.
  # ---------------------------------------------------------------------------

  mkDomain = name: idx: {
    host = "10.254.${toString idx}.1";
    sandbox = "10.254.${toString idx}.2";
    hostIface = "nvmh-${name}";
  };

  domains = {
    # general internet, ALL LAN/private ranges blocked
    browsernet = mkDomain "browsernet" 0;
    # LAN + LAN/mDNS only, no internet at all
    homenet = mkDomain "homenet" 1;
  };

  # nft forward chain for one domain. Always allow established/related replies
  # back in, allow DNS to the domain's own adguard endpoint, block cross-domain
  # traffic, then apply the domain's internet/LAN take.
  forwardChain =
    name:
    let
      d = domains.${name};
    in
    ''
      chain forward {
        type filter hook forward priority 0; policy ${if name == "homenet" then "drop" else "accept"};
        ct state established,related accept
        ip saddr ${d.sandbox}/32 ip daddr ${d.host} udp dport 53 accept
        ip saddr ${d.sandbox}/32 ip daddr ${d.host} tcp dport 53 accept
        # never let one domain talk to another
        ip saddr ${d.sandbox}/32 ip daddr 10.254.0.0/16 drop
        ${
          if name == "homenet" then
            ''
              # homenet: LAN, mDNS/SSDP/UPnP — nothing else
              ip saddr ${d.sandbox}/32 ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept
              ip saddr ${d.sandbox}/32 ip daddr 224.0.0.0/4 accept
            ''
          else
            ''
              # browsernet: everything else is fine, these are not
              ip saddr ${d.sandbox}/32 ip daddr { 100.64.0.0/10, 172.16.0.0/12, 192.168.0.0/16 } drop
              ip saddr ${d.sandbox}/32 ip daddr 10.0.0.0/8 drop
              ip saddr ${d.sandbox}/32 ip daddr 169.254.0.0/16 drop
              ip saddr ${d.sandbox}/32 ip daddr 224.0.0.0/4 udp dport 5353 drop
            ''
        }
      }
    '';
in
{
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  systemd.services = mkMerge (
    mapAttrsToList (name: d: {
      "netvm-${name}" = {
        description = "netVM domain '${name}' (veth + NAT + forward policy)";
        wantedBy = [ "multi-user.target" ];
        after = [ "systemd-modules-load.service" ];
        # CRITICAL: the script body interpolates absolute /nix/store paths for
        # ip/nft, but systemd only auto-adds store paths found in ExecStart.
        # Without `path` those binaries are absent from the unit's runtime
        # closure → "exec of 'ip' failed: No such file or directory".
        path = [
          pkgs.iproute2
          pkgs.nftables
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          ${ip} netns del ${name} 2>/dev/null || true
          ${ip} link del ${d.hostIface} 2>/dev/null || true
          ${nft} delete table inet netvm-${name} 2>/dev/null || true

          ${ip} netns add ${name}
          ${ip} link add ${d.hostIface} type veth peer name nvms-${name}
          ${ip} link set nvms-${name} netns ${name}

          ${ip} link set ${d.hostIface} up
          ${ip} addr add ${d.host}/30 dev ${d.hostIface}
          ${ip} netns exec ${name} ip link set lo up
          ${ip} netns exec ${name} ip link set nvms-${name} up
          ${ip} netns exec ${name} ip addr add ${d.sandbox}/30 dev nvms-${name}
          ${ip} netns exec ${name} ip route add default via ${d.host}

          ${nft} -f ${pkgs.writeText "netvm-${name}.nft" ''
            table inet netvm-${name} {
              chain prerouting {
                type nat hook prerouting priority dstnat; policy accept;
              }
              chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
              }
              ${forwardChain name}
            }
          ''}

          # masquerade, NOT an explicit `snat to <addr>`.
          #
          # An earlier revision avoided masquerade believing nf_nat_masquerade
          # was missing. It is not: CONFIG_NF_NAT_MASQUERADE is built into this
          # kernel and the nft_masq module is loaded, so masquerade works.
          #
          # masquerade resolves the egress address at packet time instead of at
          # rule-insert time, which is what fixes the startup failure:
          #   Error: Could not process rule: No such file or directory
          #   add rule inet netvm-* postrouting ip saddr ... snat to 192.168.1.121
          # `snat to` makes nftables resolve an address/interface while the
          # veth is still being brought up, and it has nothing to resolve
          # against yet. It also broke on every DHCP lease change.
          ${nft} add rule inet netvm-${name} postrouting \
            ip saddr ${d.sandbox}/32 masquerade
        '';
      };
    }) domains
  );
}
