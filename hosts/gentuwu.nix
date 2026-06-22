{ config, lib, ... }: {
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

  swapDevices = [{
    device = "/dev/disk/by-label/swap";
  }];

  boot.kernelParams = [ "nvidia_drm.modeset=1" ];

  environment.etc."xmrig/config.json".source = ../configs/xmrig/config-unified.json;
}
