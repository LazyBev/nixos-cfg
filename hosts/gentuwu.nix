{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "gentuwu";

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opentabletdriver.enable = true;

  boot.initrd.availableKernelModules = ["ahci" "usbhid"];
  boot.extraModulePackages = with config.boot.kernelPackages; [msi-ec];
  boot.kernelModules = ["kvm-amd" "kvm-intel" "fuse" "msi-ec"];
  boot.kernelParams = [
    "nvidia_drm.modeset=1" "nvidia.NVreg_EnableGpuFirmware=0"
    "init_on_alloc=1" "init_on_free=1" "page_alloc.shuffle=1"
    "page_poison=1" "slab_nomerge" "randomize_kstack_offset=on"
    "pti=on" "debugfs=off"
  ];
  boot.blacklistedKernelModules = [ "dccp" "sctp" "rds" "tipc" ];
  security.protectKernelImage = true;

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    open = false;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  services.xserver.videoDrivers = ["nvidia"];

  virtualisation.docker.enable = true;
  users.users.yari.extraGroups = ["kvm" "libvirtd" "docker"];

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

  environment.systemPackages = [pkgs.ocl-icd pkgs.audit];
  environment.etc."xmrig/config.json".source = lib.mkForce ../dotfiles/xmrig/config-unified.json;

  services.nbfc = {
    enable = true;
    modelName = "Cyborg 15 A12UDX";
    modelConfig = ../dotfiles/nbfc/cyborg-15-a12udx.json;
  };

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.ftrace_enabled" = false;
    "kernel.perf_event_paranoid" = 3;
    "kernel.audit" = 1;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.log_martians" = true;
    "net.ipv4.conf.default.log_martians" = true;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "dev.tty.ldisc_autoload" = 0;
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
  };

  services.fail2ban.enable = true;

  security.forcePageTableIsolation = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
}
