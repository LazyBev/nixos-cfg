{ config, lib, pkgs, inputs, ... }: {
  networking.hostName = "gentuwu";

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
  hardware.cpu.intel.updateMicrocode = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "vmd" "usbhid" ];
  boot.kernelModules = [ "kvm-amd" "kvm-intel" "fuse" ];

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

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  virtualisation.docker.enable = true;
  users.users.yari.extraGroups = [ "kvm" "libvirtd" "docker" ];

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  environment.etc."xmrig/config.json".source = lib.mkForce ../configs/xmrig/config-unified.json;
}
