{ pkgs, ... }:
let
  arti-config = pkgs.writeText "arti.toml" ''
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
  '';
in
{
  environment.systemPackages = with pkgs; [
    arti
    tor
    obfs4
    snowflake
  ];

  finit.services.arti = {
    description = "Arti Tor proxy (SOCKS on 9050/9150)";
    runlevels = "2345";
    conditions = [ "net/lo/up" ];
    path = with pkgs; [
      coreutils
      arti
      obfs4
      snowflake
    ];
    command = pkgs.writeShellScript "arti-start" ''
      mkdir -p /var/lib/arti/arti.d
      exec ${pkgs.arti}/bin/arti proxy --config ${arti-config} --config /var/lib/arti/arti.d/
    '';
    respawn = true;
  };
}
