{
  lib,
  ...
}:
{
  networking = {
    enableIPv6 = false;
    networkmanager = {
      enable = true;
      dns = lib.mkForce "none";
      wifi = {
        powersave = false;
        backend = "iwd";
        macAddress = "random";
      };
      ethernet.macAddress = "random";
    };
    wireless.iwd = {
      enable = true;
      settings = {
        Settings.AutoConnect = true;
        Network.EnableIPv6 = false;
      };
    };
    nameservers = [ "127.0.0.1" ];
  };
}
