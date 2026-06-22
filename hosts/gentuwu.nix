{ config, lib, ... }: let
  isLaptop = config.gentuwu.hardware.isLaptop;
in {
  imports = [ ./gentuwu-base.nix ];

  networking.hostName = "gentuwu";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = lib.mkIf isLaptop [{
    device = "/dev/disk/by-label/swap";
  }];

  boot.kernelParams = [ "nvidia_drm.modeset=1" ];

  environment.etc."xmrig/config.json".source =
    if isLaptop
    then ../configs/xmrig/config-laptop.json
    else ../configs/xmrig/config-desktop.json;
}
