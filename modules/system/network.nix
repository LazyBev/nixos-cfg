{ config, lib, ... }: {
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 8087 ];
}
