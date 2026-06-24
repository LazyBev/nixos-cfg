{ lib, ... }: {
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = lib.mkDefault false;
  };
}
