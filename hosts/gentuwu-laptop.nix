{ config, lib, ... }: {
  imports = [ ./hardware-configuration.nix ];

  services.upower.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [ "nvidia_drm.modeset=1" ];

  users.users.yari.extraGroups = [ "kvm" "libvirtd" ];

  swapDevices = [];
}
