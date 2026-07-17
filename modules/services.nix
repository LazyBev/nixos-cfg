{ config, lib, pkgs, ... }:
let
  nbfcCfg = config.services.nbfc;
  nbfcWrapperConfig = pkgs.writeText "nbfc.json" (builtins.toJSON {
    SelectedConfigId = nbfcCfg.modelName;
    EmbeddedControllerType = nbfcCfg.ecBackend;
  });

  monerodCfg = config.services.monerod;
  monerodPkg = pkgs.monero-cli;

  p2poolCfg = config.services.p2pool;
  chainFlag =
    if p2poolCfg.chain == "mini" then "--mini"
    else if p2poolCfg.chain == "nano" then "--nano"
    else "";
in {
  options = {
    services.monerod = {
      enable = lib.mkEnableOption "Monero daemon (monerod)";
      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/monerod";
      };
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
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

    services.nbfc = {
      enable = lib.mkEnableOption "NBFC fan control service";
      package = lib.mkPackageOption pkgs "nbfc-linux" {};
      modelName = lib.mkOption {
        type = lib.types.str;
        description = "Notebook model name";
      };
      modelConfig = lib.mkOption {
        type = lib.types.path;
        description = "Path to the notebook model JSON config file";
      };
      ecBackend = lib.mkOption {
        type = lib.types.str;
        default = "dev_port";
      };
    };

    services.p2pool = {
      enable = lib.mkEnableOption "P2Pool node";
      wallet = lib.mkOption {
        type = lib.types.str;
        description = "Monero wallet address for mining payouts";
        example = "48...";
      };
      chain = lib.mkOption {
        type = lib.types.enum [ "main" "mini" "nano" ];
        default = "mini";
      };
      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/p2pool";
      };
      extraArgs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
      monerodHost = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
      };
      monerodRpcPort = lib.mkOption {
        type = lib.types.port;
        default = 18081;
      };
      stratumPort = lib.mkOption {
        type = lib.types.port;
        default = 3333;
      };
      p2pPort = lib.mkOption {
        type = lib.types.port;
        default = 37888;
      };
    };
  };

  config = lib.mkMerge [
    {
      services.adguardhome = {
        enable = true;
        host = "0.0.0.0";
        port = 8080;
        mutableSettings = true;
        settings = {
          schema_version = 22;
          dns = {
            port = 53;
            bind_hosts = [ "127.0.0.1" ];
            upstream_dns = [
              "https://dns.quad9.net/dns-query"
              "https://dns.cloudflare.com/dns-query"
            ];
            upstream_dns_file = "";
            bootstrap_dns = [ "9.9.9.9" "1.1.1.1" ];
            fallback_dns = [ "https://dns.cloudflare.com/dns-query" ];
          };
        };
      };

      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-mozc
          fcitx5-gtk
          qt6Packages.fcitx5-configtool
        ];
      };

      services.flatpak = {
        enable = true;
        remotes = [{
          name = "flathub";
          location = "https://flathub.org/repo/flathub.flatpakrepo";
        }];
        packages = [
          "com.stremio.Stremio"
          "org.vinegarhq.Sober"
          "com.spotify.Client"
        ];
        overrides.global.Environment.GTK_THEME = "Dracula";
      };

      services.gvfs.enable = true;

      services.i2pd = {
        enable = true;
        address = "127.0.0.1";
        proto = {
          http.enable = true;
          socksProxy.enable = true;
          httpProxy.enable = true;
          sam.enable = true;
          i2cp = {
            enable = false;
            address = "127.0.0.1";
            port = 7654;
          };
        };
      };

      services.openssh.enable = true;
      services.openssh.settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    }
    (lib.mkIf monerodCfg.enable {
      users.users.monerod = {
        description = "Monero daemon user";
        home = monerodCfg.dataDir;
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
              --data-dir ${monerodCfg.dataDir} \
              --rpc-bind-ip 0.0.0.0 \
              --rpc-bind-port ${toString monerodCfg.rpcPort} \
              --zmq-pub tcp://127.0.0.1:${toString monerodCfg.zmqPort} \
              --confirm-external-bind \
              --p2p-bind-ip 0.0.0.0 \
              --p2p-bind-port ${toString monerodCfg.p2pPort} \
              --out-peers 32 --in-peers 64 \
              --add-priority-node=p2pmd.xmrvsbeast.com:18080 \
              --add-priority-node=nodes.hashvault.pro:18080 \
              --enforce-dns-checkpointing --enable-dns-blocklist \
              --prune-blockchain --non-interactive \
              --max-log-file-size 0 --log-level 0 \
              ${lib.escapeShellArgs monerodCfg.extraArgs}
          '';
          Restart = "on-failure";
          RestartSec = "30";
          LimitNOFILE = 65536;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [ monerodCfg.dataDir ];
        };
      };
    })
    (lib.mkIf nbfcCfg.enable {
      environment.systemPackages = [ nbfcCfg.package ];
      systemd.tmpfiles.rules = [
        "d /var/lib/nbfc 0755 root root -"
        "d /var/lib/nbfc/configs 0755 root root -"
        "L+ /var/lib/nbfc/configs/${nbfcCfg.modelName}.json - - - - ${nbfcCfg.modelConfig}"
      ];
      systemd.services.nbfc = {
        description = "NoteBook FanControl";
        after = [ "sysinit.target" ];
        wantedBy = [ "multi-user.target" ];
        wants = [ "systemd-tmpfiles-setup.service" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${nbfcCfg.package}/bin/nbfc_service -c ${nbfcWrapperConfig} -e ${nbfcCfg.ecBackend}";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
      boot.kernelModules = [ "ec_sys" ];
    })
    (lib.mkIf p2poolCfg.enable {
      users.users.p2pool = {
        description = "P2Pool user";
        home = p2poolCfg.dataDir;
        createHome = true;
        isSystemUser = true;
        group = "p2pool";
      };
      users.groups.p2pool = {};
      systemd.services.p2pool = {
        description = "P2Pool node (${p2poolCfg.chain} chain)";
        after = [ "network.target" "monerod.service" ];
        wants = [ "monerod.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          User = "p2pool";
          Group = "p2pool";
          ExecStart = ''
            ${pkgs.p2pool}/bin/p2pool \
              --host ${p2poolCfg.monerodHost} \
              --rpc-port ${toString p2poolCfg.monerodRpcPort} \
              --wallet ${p2poolCfg.wallet} \
              ${chainFlag} \
              --data-dir ${p2poolCfg.dataDir} \
              --stratum 0.0.0.0:${toString p2poolCfg.stratumPort} \
              ${lib.escapeShellArgs p2poolCfg.extraArgs}
          '';
          Restart = "on-failure";
          RestartSec = "30";
          LimitNOFILE = 65536;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [ p2poolCfg.dataDir ];
        };
      };
    })
  ];
}
