{ config, lib, ... }: let
  isLaptop = config.gentuwu.hardware.isLaptop;
in {
  options.gentuwu.hardware.isLaptop = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = {
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

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia.prime = lib.mkIf isLaptop {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    virtualisation.docker.enable = true;
    users.users.yari.extraGroups = [ "kvm" "libvirtd" "docker" ];

    services.upower.enable = lib.mkIf isLaptop true;

    gentuwu.powerProfiles.default = lib.mkIf (!isLaptop) "performance";
  };
}
