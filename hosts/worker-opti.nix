{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/miner.nix
    ../modules/users/yari.nix
  ];

  networking.hostName = "worker-opti";

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

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

  environment.systemPackages = with pkgs; [
    xmrig
    git
    just
    nh
    vim
  ];
  environment.etc."xmrig/config.json".source = ../dotfiles/xmrig/config-worker-opti.json;

  systemd.services.xmrig = {
    description = "Monero miner";
    serviceConfig = {
      ExecStart = "${pkgs.xmrig}/bin/xmrig --config=/etc/xmrig/config.json";
      Restart = "on-failure";
    };
  };

  networking.networkmanager.wifi.powersave = false;
}
