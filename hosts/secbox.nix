{ config, lib, pkgs, ... }: {
  imports = [
    ../modules/system/vars.nix
    ../modules/system/nix.nix
    ../modules/programs/secbox-common.nix
    ../modules/programs/security-tools.nix
    ../modules/security/tor-hardening.nix
    ../modules/users/pentest.nix
  ];

  vars.hostname = "secbox";
  vars.flakeDir = "/home/pentest/nixos-cfg";

  networking.hostId = "c0ffee01";
  networking.hostName = "secbox";
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  boot.kernelParams = [
    "page_poison=1"
    "randomize_kstack_offset=on"
    "pti=on"
    "vsyscall=none"
    "debugfs=off"
  ];

  security.protectKernelImage = true;

  environment.systemPackages = [ pkgs.audit ];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
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

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  nix.settings.trusted-users = [ "pentest" ];

  system.stateVersion = "25.05";
}
