{ pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [ 22 ];

  systemd.services.dropbear = {
    description = "Dropbear SSH server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      mkdir -p /etc/dropbear
      if [ ! -f /etc/dropbear/dropbear_rsa_host_key ]; then
        ${pkgs.dropbear}/bin/dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
      fi
    '';
    serviceConfig = {
      ExecStart = "${pkgs.dropbear}/bin/dropbear -p 22 -r /etc/dropbear/dropbear_rsa_host_key -F -s -w -K 300";
      Restart = "on-failure";
      RestartSec = "5";
    };
  };

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      factor = "2";
      maxtime = "12h";
      overalljails = true;
    };
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ];
    jails = {
      sshd = {
        settings = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          maxretry = 3;
          bantime = "1h";
          findtime = "10m";
        };
      };
    };
  };
}
