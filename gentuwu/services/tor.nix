{
  config,
  lib,
  pkgs,
  ...
}:
{
  # tun2socks: userspace SOCKS5 tunnel used by topaz --tor on
  # (kernel modules are locked, so iptables/nft nat redirection is
  # impossible; the tun-based route works without any modules)
  environment.systemPackages = [
    pkgs.tun2socks
    pkgs.arti
    pkgs.tor
    pkgs.obfs4 # lyrebird: obfs4 + webtunnel
    pkgs.snowflake
  ];

  # real tor daemon for `topaz --tor tor on`. Runs as uid 35 (NixOS's fixed
  # uid for tor), which is the uid topaz exempts from its tunnel so tor can
  # reach relays directly. NOT started at boot: arti holds SocksPort 9050 by
  # default, and topaz starts whichever backend it needs (stopping the other).
  services.tor = {
    enable = true;
    client.enable = true;
  };
  systemd.services.tor.wantedBy = lib.mkForce [ ];

  # tor replaced by arti (rust tor client); SOCKS on 9050 + 9150.
  #
  # Bridge-ready: the pluggable transports below are wired up but no
  # bridge lines are active, so arti connects directly (works in the
  # clear / uncensored networks). To enable bridges, drop a file like
  #
  #   [bridges]
  #   bridges = [
  #     "Bridge obfs4 <ip>:<port> <fp> cert=... iat-mode=0",
  #     "Bridge snowflake 192.0.2.1:80 2B280B23E1107BB62ABFC40DDCC882B464A844FC",
  #   ]
  #
  # into /var/lib/arti/arti.d/ and `systemctl restart arti`. Fetch fresh
  # lines from https://bridges.torproject.org/ when you need them.
  systemd.services.arti = {
    description = "Arti Tor proxy (SOCKS on 9050/9150, bridge-ready)";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = "mkdir -p /var/lib/arti/arti.d";
    serviceConfig = {
      ExecStart = "${pkgs.arti}/bin/arti proxy --config ${pkgs.writeText "arti.toml" ''
        [application]
        allow_running_as_root = true

        [proxy]
        socks_listen = ["127.0.0.1:9050", "127.0.0.1:9150"]

        [bridges]
        enabled = "auto"

        [[bridges.transports]]
        protocols = ["obfs4", "webtunnel"]
        path = "${pkgs.obfs4}/bin/lyrebird"
        arguments = []
        run_on_startup = false

        [[bridges.transports]]
        protocols = ["snowflake"]
        path = "${pkgs.snowflake}/bin/client"
        arguments = []
        run_on_startup = false
      ''} --config /var/lib/arti/arti.d/";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
