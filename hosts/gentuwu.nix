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

  boot.extraModulePackages = with config.boot.kernelPackages; [ msi-ec ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "vmd" "usbhid" ];
  boot.kernelModules = [ "kvm-amd" "kvm-intel" "fuse" "msi-ec" ];

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

  services.mpd = {
    enable = true;
    user = "yari";
    dataDir = "/home/yari/.mpd";
    settings = {
      music_directory = "/home/yari/Music";
      audio_output = [
        {
          type = "pulse";
          name = "PulseAudio (via PipeWire)";
          server = "/run/user/${toString config.users.users.yari.uid}/pulse/native";
        }
      ];
    };
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  environment.systemPackages = [ pkgs.ocl-icd ];
  environment.etc."xmrig/config.json".source = lib.mkForce ../configs/xmrig/config-unified.json;

  services.nbfc = {
    enable = true;
    modelName = "Cyborg 15 A12UDX";
    modelConfig = ../configs/nbfc/cyborg-15-a12udx.json;
  };
}
