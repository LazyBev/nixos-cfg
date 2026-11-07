{ lib, pkgs, ... }:
let
  inherit (lib) mapAttrsToList mkMerge;

  ip = "${pkgs.iproute2}/bin/ip";
  nft = "${pkgs.nftables}/bin/nft";

  mkDomain = name: idx: {
    host = "10.254.${toString idx}.1";
    sandbox = "10.254.${toString idx}.2";
    hostIface = "nvmh-${name}";
  };

  domains = {
    browsernet = mkDomain "browsernet" 0;
    homenet = mkDomain "homenet" 1;
  };

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
        ip saddr ${d.sandbox}/32 ip daddr 10.254.0.0/16 drop
        ${
          if name == "homenet" then
            ''
              ip saddr ${d.sandbox}/32 ip daddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept
              ip saddr ${d.sandbox}/32 ip daddr 224.0.0.0/4 accept
            ''
          else
            ''
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

  finit.tasks = mkMerge (
    mapAttrsToList (name: d: {
      "netvm-${name}" = {
        description = "netVM domain '${name}' (veth + NAT + forward policy)";
        runlevels = "2345";
        path = [
          pkgs.iproute2
          pkgs.nftables
        ];
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

          ${nft} add rule inet netvm-${name} postrouting \
            ip saddr ${d.sandbox}/32 masquerade
        '';
      };
    }) domains
  );
}
