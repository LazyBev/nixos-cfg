{ config, lib, ... }: {
  vars.hostname = "secbox-laptop";
  vars.name = "secbox-laptop";
  vars.flakeDir = "/home/pentest/nixos-cfg";

  networking.hostId = lib.mkForce "c0ffee02";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

  services.throttled.enable = true;
  services.tlp.enable = true;
  services.power-profiles-daemon.enable = lib.mkForce false;
  gentuwu.powerProfiles.default = lib.mkForce null;
  services.logind.settings.Login.HandleLidSwitch = lib.mkForce "suspend";

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
