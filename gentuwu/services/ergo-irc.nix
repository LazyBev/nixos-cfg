{
  pkgs,
  config,
  lib,
  ...
}:
let
  h = import ../../lib/helpers.nix { inherit lib; };
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
          "kill"
          "ban"
          "nofakelag"
          "relaymsg"
          "vhosts"
          "sajoin"
          "samode"
          "snomasks"
          "roleplay"
        ];
      };
      "server-admin" = {
        title = "Server Admin";
        extends = "chat-moderator";
        capabilities = [
          "rehash"
          "accreg"
          "chanreg"
          "history"
          "defcon"
          "massmessage"
          "metadata"
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
    logging = [
      {
        method = "stderr";
        type = "* -userinput -useroutput";
        level = "info";
      }
    ];
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
  options.services.ergo-irc = {
    enable = lib.mkEnableOption "Ergo IRC server";
    serverName = h.mkStrOpt "irc.rah.net" "IRC server name";
    networkName = h.mkStrOpt "rah" "IRC network name";
    dataDir = h.mkPathOpt "/var/lib/ergo-irc" "Ergo data directory";
    plaintextPort = h.mkPortOpt 6667 "Plaintext IRC port";
    tlsPort = h.mkPortOpt 6697 "TLS IRC port";
    operPasswordHash = h.mkStrOpt (builtins.getEnv "ERGO_OPER_PASSWORD") "Bcrypt hash of the operator password (use ergo genpasswd)";
  };

  config = lib.mkIf ircCfg.enable {
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
      after = [
        "network.target"
        "ergo-tls-init.service"
      ];
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
  };
}
