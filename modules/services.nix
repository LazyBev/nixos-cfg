{
  config,
  lib,
  pkgs,
  ...
}:
let
  h = import ../lib/helpers.nix { inherit lib; };
  nbfcCfg = config.services.nbfc;
  nbfcWrapperConfig = pkgs.writeText "nbfc.json" (
    builtins.toJSON {
      SelectedConfigId = nbfcCfg.modelName;
      EmbeddedControllerType = nbfcCfg.ecBackend;
    }
  );

  monerodCfg = config.services.monerod;
  monerodPkg = pkgs.monero-cli;

  p2poolCfg = config.services.p2pool;
  chainFlag =
    if p2poolCfg.chain == "mini" then
      "--mini"
    else if p2poolCfg.chain == "nano" then
      "--nano"
    else
      "";

  ircCfg = config.services.ergo-irc;
  ergoConfig = {
    network.name = ircCfg.networkName;
    server = {
      name = ircCfg.serverName;
      listeners = {
        ":${toString ircCfg.plaintextPort}" = { };
        ":${toString ircCfg.tlsPort}" = {
          tls = {
            cert = "${ircCfg.dataDir}/cert.pem";
            key = "${ircCfg.dataDir}/key.pem";
          };
          min-tls-version = "1.2";
        };
      };
      lookup-hostnames = false;
      ip-cloaking = {
        enabled = true;
        netname = ircCfg.networkName;
        num-bits = 64;
      };
      idle-timeouts = {
        registration = "60s";
        ping = "1m30s";
        disconnect = "2m30s";
      };
    };
    accounts = {
      authentication-enabled = true;
      registration = {
        enabled = true;
        allow-before-connect = true;
        throttling = {
          enabled = true;
          duration = "10m";
          max-attempts = 30;
        };
        bcrypt-cost = 4;
        verify-timeout = "32h";
        email-verification.enabled = false;
      };
      login-throttling = {
        enabled = true;
        duration = "1m";
        max-attempts = 3;
      };
      nick-reservation = {
        enabled = true;
        method = "strict";
        force-nick-equals-account = true;
      };
      multiclient = {
        enabled = true;
        allowed-by-default = true;
        always-on = "opt-in";
      };
      default-user-modes = "+i";
    };
    channels = {
      default-modes = "+ntC";
      max-channels-per-client = 100;
      registration.enabled = true;
    };
    oper-classes = {
      "chat-moderator" = {
        title = "Chat Moderator";
        capabilities = [
          "kill" "ban" "nofakelag" "relaymsg" "vhosts"
          "sajoin" "samode" "snomasks" "roleplay"
        ];
      };
      "server-admin" = {
        title = "Server Admin";
        extends = "chat-moderator";
        capabilities = [
          "rehash" "accreg" "chanreg" "history"
          "defcon" "massmessage" "metadata"
        ];
      };
    };
    opers = {
      yari = {
        class = "server-admin";
        hidden = true;
        whois-line = "is the server administrator";
        password = ircCfg.operPasswordHash;
      };
    };
    logging = [{
      method = "stderr";
      type = "* -userinput -useroutput";
      level = "info";
    }];
    datastore = {
      path = "${ircCfg.dataDir}/ircd.db";
      autoupgrade = true;
    };
    history = {
      enabled = true;
      channel-length = 2048;
      client-length = 256;
      chathistory-maxmessages = 1000;
      restrictions.expire-time = "1w";
    };
  };
in
{
  options = {
    services.monerod = {
      enable = lib.mkEnableOption "Monero daemon (monerod)";
      dataDir = h.mkPathOpt "/var/lib/monerod" "Monero daemon data directory";
      extraArgs = h.mkListOpt lib.types.str [ ] "Extra arguments for monerod";
      rpcPort = h.mkPortOpt 18081 "Monero RPC port";
      p2pPort = h.mkPortOpt 18080 "Monero P2P port";
      zmqPort = h.mkPortOpt 18083 "Monero ZMQ port";
    };

    services.nbfc = {
      enable = lib.mkEnableOption "NBFC fan control service";
      package = lib.mkPackageOption pkgs "nbfc-linux" { };
      modelName = h.mkStrOpt "" "Notebook model name";
      modelConfig = h.mkPathOpt "" "Path to the notebook model JSON config file";
      ecBackend = h.mkStrOpt "dev_port" "Embedded controller backend";
    };

    services.p2pool = {
      enable = lib.mkEnableOption "P2Pool node";
      wallet = h.mkStrOpt "" "Monero wallet address for mining payouts";
      chain = lib.mkOption {
        type = lib.types.enum [ "main" "mini" "nano" ];
        default = "mini";
      };
      dataDir = h.mkPathOpt "/var/lib/p2pool" "P2Pool data directory";
      extraArgs = h.mkListOpt lib.types.str [ ] "Extra arguments for p2pool";
      monerodHost = h.mkStrOpt "127.0.0.1" "Monero daemon host";
      monerodRpcPort = h.mkPortOpt 18081 "Monero daemon RPC port";
      stratumPort = h.mkPortOpt 3333 "P2Pool stratum port";
      p2pPort = h.mkPortOpt 37888 "P2Pool P2P port";
    };

    services.ergo-irc = {
      enable = lib.mkEnableOption "Ergo IRC server";
      serverName = h.mkStrOpt "irc.rah.net" "IRC server name";
      networkName = h.mkStrOpt "rah" "IRC network name";
      dataDir = h.mkPathOpt "/var/lib/ergo-irc" "Ergo data directory";
      plaintextPort = h.mkPortOpt 6667 "Plaintext IRC port";
      tlsPort = h.mkPortOpt 6697 "TLS IRC port";
      operPasswordHash = h.mkStrOpt "" "Bcrypt hash of the operator password (use ergo genpasswd)";
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
            bootstrap_dns = [
              "9.9.9.9"
              "1.1.1.1"
            ];
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
        remotes = [
          {
            name = "flathub";
            location = "https://flathub.org/repo/flathub.flatpakrepo";
          }
        ];
        packages = [
          "com.stremio.Stremio"
          "org.vinegarhq.Sober"
          "com.spotify.Client"
        ];
        overrides.global.Environment.GTK_THEME = "catppuccin-mocha-mauve";
      };
      services.blueman.enable = true;
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
      users.groups.monerod = { };
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
          PrivateTmp = h.hardenService.privateTmp;
          ProtectSystem = h.hardenService.protectSystem;
          ProtectHome = h.hardenService.protectHome;
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
      users.groups.p2pool = { };
      systemd.services.p2pool = {
        description = "P2Pool node (${p2poolCfg.chain} chain)";
        after = [
          "network.target"
          "monerod.service"
        ];
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
          PrivateTmp = h.hardenService.privateTmp;
          ProtectSystem = h.hardenService.protectSystem;
          ProtectHome = h.hardenService.protectHome;
          ReadWritePaths = [ p2poolCfg.dataDir ];
        };
      };
    })
    (lib.mkIf ircCfg.enable {
      users.users.ergo = {
        description = "Ergo IRC server";
        home = ircCfg.dataDir;
        createHome = true;
        isSystemUser = true;
        group = "ergo";
      };
      users.groups.ergo = { };

      systemd.services.ergo-tls-init = {
        description = "Generate self-signed TLS certificate for Ergo";
        before = [ "ergo-irc.service" ];
        wantedBy = [ "ergo-irc.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "ergo-tls-init" ''
            if [ ! -f "${ircCfg.dataDir}/cert.pem" ]; then
              ${pkgs.openssl}/bin/openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 \
                -keyout "${ircCfg.dataDir}/key.pem" \
                -out "${ircCfg.dataDir}/cert.pem" \
                -days 3650 -nodes \
                -subj "/CN=${ircCfg.serverName}" \
                -addext "subjectAltName=DNS:${ircCfg.serverName}"
              chmod 600 "${ircCfg.dataDir}/key.pem"
              chmod 644 "${ircCfg.dataDir}/cert.pem"
            fi
          '';
        };
      };

      systemd.services.ergo-irc = {
        description = "Ergo IRC Server";
        after = [ "network.target" "ergo-tls-init.service" ];
        wants = [ "ergo-tls-init.service" ];
        wantedBy = [ "multi-user.target" ];
        preStart = ''
          cp ${(pkgs.formats.yaml { }).generate "ergo-ircd.yaml" ergoConfig} ${ircCfg.dataDir}/ircd.yaml
          chown ergo:ergo ${ircCfg.dataDir}/ircd.yaml
        '';
        serviceConfig = {
          Type = "simple";
          User = "ergo";
          Group = "ergo";
          ExecStart = "${pkgs.ergochat}/bin/ergo run";
          WorkingDirectory = ircCfg.dataDir;
          Restart = "on-failure";
          RestartSec = "5";
          LimitNOFILE = 65536;
          PrivateTmp = h.hardenService.privateTmp;
          ProtectSystem = h.hardenService.protectSystem;
          ProtectHome = h.hardenService.protectHome;
          ReadWritePaths = [ ircCfg.dataDir ];
        };
      };

      networking.firewall.allowedTCPPorts = [
        ircCfg.plaintextPort
        ircCfg.tlsPort
      ];
    })
  ];
}
