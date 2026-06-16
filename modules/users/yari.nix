{ config, pkgs, ... }: {
  users.users.yari = {
    isNormalUser = true;
    description = "yari";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
    initialPassword = "changeme";
  };
  users.defaultUserShell = pkgs.fish;
}
