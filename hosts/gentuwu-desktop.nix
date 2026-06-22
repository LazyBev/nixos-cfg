{ config, lib, ... }: {
  imports = [ ./gentuwu-base.nix ];

  gentuwu.hardware.isLaptop = false;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [];

  boot.kernelParams = [ "nvidia_drm.modeset=1" ];
}
