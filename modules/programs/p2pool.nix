{ config, lib, pkgs, ... }:
let
  cfg = config.services.p2pool;
  chainFlag =
    if cfg.chain == "mini" then "--mini"
    else if cfg.chain == "nano" then "--nano"
    else "";
  stratumPort = cfg.stratumPort;
in {
  options.services.p2pool = {
    enable = lib.mkEnableOption "P2Pool node";

    wallet = lib.mkOption {
      type = lib.types.str;
      description = "Monero wallet address for mining payouts";
      example = "48...";
    };

    chain = lib.mkOption {
      type = lib.types.enum [ "main" "mini" "nano" ];
      default = "mini";
      description = "P2Pool chain to mine on";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/p2pool";
      description = "Data directory for P2Pool";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Extra command-line arguments for P2Pool";
    };

    monerodHost = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Monero daemon RPC host";
    };

    monerodRpcPort = lib.mkOption {
      type = lib.types.port;
      default = 18081;
    };

    stratumPort = lib.mkOption {
      type = lib.types.port;
      default = 3333;
      description = "Stratum server port for miners to connect";
    };

    p2pPort = lib.mkOption {
      type = lib.types.port;
      default =
        if cfg.chain == "mini" then 37888
        else if cfg.chain == "nano" then 37890
        else 37889;
      description = "P2Pool P2P port";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.p2pool = {
      description = "P2Pool user";
      home = cfg.dataDir;
      createHome = true;
      isSystemUser = true;
      group = "p2pool";
    };
    users.groups.p2pool = {};

    systemd.services.p2pool = {
      description = "P2Pool node (${cfg.chain} chain)";
      after = [ "network.target" "monerod.service" ];
      wants = [ "monerod.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = "p2pool";
        Group = "p2pool";
        ExecStart = ''
          ${pkgs.p2pool}/bin/p2pool \
            --host ${cfg.monerodHost} \
            --rpc-port ${toString cfg.monerodRpcPort} \
            --wallet ${cfg.wallet} \
            ${chainFlag} \
            --data-dir ${cfg.dataDir} \
            --stratum 127.0.0.1:${toString stratumPort} \
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
