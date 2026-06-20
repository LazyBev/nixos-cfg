{ config, lib, ... }: {
  networking.networkmanager.enable = true;
  networking.hostName = config.vars.hostname;
  networking.hostId = "c0ffee42";
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 8087 ];
}
