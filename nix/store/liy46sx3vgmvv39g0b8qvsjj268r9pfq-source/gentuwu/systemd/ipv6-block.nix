{
  pkgs,
  ...
}:
{
  systemd.services.ipv6-block = {
    description = "Block IPv6 output traffic";
    after = [ "firewall.service" ];
    requires = [ "firewall.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    path = [ pkgs.nftables ];
    preStart = ''
      nft add table inet ipv6block 2>/dev/null || true
      nft flush table inet ipv6block 2>/dev/null || true
      nft add chain inet ipv6block output '{ type filter hook output priority -5; policy accept; }'
      nft add rule inet ipv6block output oifname "lo" accept
      nft add rule inet ipv6block output meta nfproto ipv6 drop
    '';
    preStop = ''
      nft delete table inet ipv6block 2>/dev/null || true
    '';
  };
}
