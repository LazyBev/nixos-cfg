{ config, lib, ... }: {
  imports = [ ./gentuwu-base.nix ./hardware-configuration.nix ];

  gentuwu.hardware.isLaptop = true;

  swapDevices = [];

  boot.kernelParams = [ "nvidia_drm.modeset=1" ];

  environment.etc."xmrig/config.json".source = lib.mkForce ../configs/xmrig/config-laptop.json;
}
