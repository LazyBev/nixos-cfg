{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "gentuwu";

  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.ethernet.macAddress = "random";

  programs.appimage = {
    enable = true;
    binfmt = true;
  };
  hardware.enableRedistributableFirmware = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opentabletdriver.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        # Shows battery charge of connected devices on supported
        # Bluetooth adapters. Defaults to 'false'.
        Experimental = true;
        # When enabled other devices can connect faster to us, however
        # the tradeoff is increased power consumption. Defaults to
        # 'false'.
        FastConnectable = true;
      };
      Policy = {
        # Enable all controllers when they are found. This includes
        # adapters present on start as well as adapters that are plugged
        # in later on. Defaults to 'true'.
        AutoEnable = true;
      };
    };
  };
  boot.initrd.availableKernelModules = [
    "ahci"
    "usbhid"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ msi-ec ];
  boot.kernelModules = [
    "kvm-amd"
    "kvm-intel"
    "fuse"
    "msi-ec"
  ];
  boot.kernelParams = [
    "nvidia_drm.modeset=1"
    "nvidia.NVreg_EnableGpuFirmware=0"
    "init_on_alloc=1"
    "init_on_free=1"
    "page_alloc.shuffle=1"
    "page_poison=1"
    "slab_nomerge"
    "randomize_kstack_offset=on"
    "pti=on"
    "debugfs=off"
  ];
  boot.blacklistedKernelModules = [
    "dccp"
    "sctp"
    "rds"
    "tipc"
  ];
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
  services.xserver.videoDrivers = [ "nvidia" ];

  virtualisation.docker.enable = true;
  users.users.yari.extraGroups = [
    "kvm"
    "libvirtd"
    "docker"
  ];

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

  environment.systemPackages = [
    pkgs.ocl-icd
    pkgs.audit
  ];
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

  services.tor = {
    enable = true;
    client.enable = true;
    relay.enable = false;
    settings = {
      SOCKSPort = [{
        addr = "127.0.0.1";
        port = 9050;
        flags = [
          "IsolateDestAddr"
          "IsolateDestPort"
          "IsolateClientProtocol"
          "IsolateSOCKSAuth"
        ];
      }];
      TransPort = [{ addr = "127.0.0.1"; port = 9040; }];
      DNSPort = [{ addr = "127.0.0.1"; port = 5353; }];
      ControlPort = [{ addr = "127.0.0.1"; port = 9051; }];
      CookieAuthentication = true;
      VirtualAddrNetwork = "10.192.0.0/10";
      AutomapHostsOnResolve = true;
      StrictNodes = true;
      SafeLogging = true;
      SafeSocks = true;
      DisableDebuggerAttachment = true;
      EnforceDistinctSubnets = true;
      GeoIPExcludeUnknown = true;
      HardwareAccel = true;
      NewCircuitPeriod = 15;
      MaxCircuitDirtiness = 300;
      CircuitStreamTimeout = 180;
      LearnCircuitBuildTimeout = false;
      CircuitBuildTimeout = 30;
      NumEntryGuards = 3;
      NumCPUs = 0;
      BandwidthRate = 0;
      BandwidthBurst = 0;
    };
  };

  services.fail2ban.enable = true;

  security.forcePageTableIsolation = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  systemd.services.protonvpn-killswitch = {
    description = "Proton VPN killswitch: block non-VPN traffic";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ iptables ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      if ! ip link show proton0 >/dev/null 2>&1; then
        echo "proton0 interface not found, skipping killswitch"
        exit 0
      fi

      iptables -N PROTON_KS 2>/dev/null || iptables -F PROTON_KS
      iptables -A PROTON_KS -o lo -j ACCEPT
      iptables -A PROTON_KS -o proton0 -j ACCEPT
      iptables -A PROTON_KS -m state --state ESTABLISHED,RELATED -j ACCEPT
      iptables -A PROTON_KS -j DROP
      iptables -A OUTPUT -j PROTON_KS

      ip6tables -P OUTPUT DROP 2>/dev/null || true
    '';
    preStop = ''
      iptables -D OUTPUT -j PROTON_KS 2>/dev/null || true
      iptables -F PROTON_KS 2>/dev/null || true
      iptables -X PROTON_KS 2>/dev/null || true
      ip6tables -P OUTPUT ACCEPT 2>/dev/null || true
    '';
  };
}
