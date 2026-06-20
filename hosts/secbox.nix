{ config, lib, ... }: {
  vars.hostname = "secbox";
  vars.name = "secbox";
  vars.flakeDir = "/home/pentest/nixos-cfg";

  networking.hostId = lib.mkForce "c0ffee01";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [ ];

  imports = [ ../modules/programs/secbox-common.nix ];
}
