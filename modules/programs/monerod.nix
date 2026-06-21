{ config, lib, pkgs, ... }:
let
  cfg = config.services.monerod;
  monerodPkg = pkgs.monero-cli;
in {
  options.services.monerod = {
    enable = lib.mkEnableOption "Monero daemon (monerod)";
    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/monerod";
      description = "Data directory for monerod blockchain";
    };
    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra command-line arguments for monerod";
    };
    rpcPort = lib.mkOption {
      type = lib.types.port;
      default = 18081;
    };
    p2pPort = lib.mkOption {
      type = lib.types.port;
      default = 18080;
    };
    zmqPort = lib.mkOption {
      type = lib.types.port;
      default = 18083;
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.monerod = {
      description = "Monero daemon user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "monerod";
    };
    users.groups.monerod = {};

    systemd.services.monerod = {
      description = "Monero Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "monerod";
        Group = "monerod";
        ExecStart = ''
          ${monerodPkg}/bin/monerod \
            --data-dir ${cfg.dataDir} \
            --rpc-bind-ip 0.0.0.0 \
            --rpc-bind-port ${toString cfg.rpcPort} \
            --zmq-pub tcp://127.0.0.1:${toString cfg.zmqPort} \
            --confirm-external-bind \
            --p2p-bind-ip 0.0.0.0 \
            --p2p-bind-port ${toString cfg.p2pPort} \
            --out-peers 32 \
            --in-peers 64 \
            --add-priority-node=p2pmd.xmrvsbeast.com:18080 \
            --add-priority-node=nodes.hashvault.pro:18080 \
            --enforce-dns-checkpointing \
            --enable-dns-blocklist \
            --prune-blockchain \
            --non-interactive \
            --max-log-file-size 0 \
            --log-level 0 \
            ${lib.escapeShellArgs cfg.extraArgs}
        '';
        Restart = "on-failure";
        RestartSec = "30";
        LimitNOFILE = 65536;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      };
    };
  };
}
