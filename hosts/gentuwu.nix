{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  h = import ../lib/helpers.nix { inherit lib; };
in
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
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
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
    "nft_reject"
    "nf_reject_ipv4"
    "nf_reject_ipv6"
    "nft_reject_inet"
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
    "apparmor=1"
    "lsm=lockdown,capability,yama,apparmor,bpf"
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

  services.ergo-irc = {
    enable = true;
    operPasswordHash = "$2a$04$bgk5F5D6N/pDexnAXA6Bzeqf7xbBDYr5dm7dMKf4ixlZ3f8bCtvi6";
  };

  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  environment.systemPackages = [
    pkgs.ocl-icd
    pkgs.audit
    pkgs.obfs4
    pkgs.nftables
  ];

  # Add cargo bin to PATH for locally-built tools (topaz, etc.)
  environment.sessionVariables.CARGO_HOME = [ "/home/yari/.cargo" ];
  programs.fish.shellInit = ''
    set -gx PATH "$HOME/.cargo/bin" $PATH
  '';

  # ClamAV: auto-scan downloads
  services.clamav = {
    updater.enable = true;
    updater.interval = "hourly";
    daemon.enable = true;
    scanner = {
      enable = true;
      interval = "hourly";
      scanDirectories = [ "/home/yari/Downloads" ];
    };
  };

  # Instant scan on download: watch ~/Downloads for new files
  systemd.paths.clamav-watch-downloads = {
    description = "Watch ~/Downloads for new files to scan";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = "/home/yari/Downloads";
      Unit = "clamav-scan-download.service";
    };
  };
  systemd.services.clamav-scan-download = {
    description = "Scan new download with ClamAV";
    after = [ "clamav-daemon.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      OUTPUT=$(${pkgs.clamav}/bin/clamdscan --infected /home/yari/Downloads/ 2>&1)
      if echo "$OUTPUT" | grep -q "FOUND"; then
        ${pkgs.libnotify}/bin/notify-send -u critical "Malware detected!" "$(echo "$OUTPUT" | grep FOUND)"
      fi
    '';
  };
  environment.etc."xmrig/config.json".source = lib.mkForce ../dotfiles/xmrig/config-unified.json;

  services.nbfc = {
    enable = true;
    modelName = "Cyborg 15 A12UDX";
    modelConfig = ../dotfiles/nbfc/cyborg-15-a12udx.json;
  };

  boot.kernel.sysctl = h.securitySysctl // {
    "kernel.audit" = 1;
    "kernel.sysrq" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_ra" = 0;
    "net.ipv6.conf.default.accept_ra" = 0;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.tcp_timestamps" = 0;
    "dev.tty.ldisc_autoload" = 0;
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
  };

  services.tor = {
    enable = true;
    client.enable = true;
    relay.enable = false;
    settings = {
      SOCKSPort = lib.mkForce [
        {
          addr = "127.0.0.1";
          port = 9050;
          flags = [
            "IsolateDestAddr"
            "IsolateDestPort"
            "IsolateClientProtocol"
            "IsolateSOCKSAuth"
          ];
        }
      ];
      TransPort = [
        {
          addr = "127.0.0.1";
          port = 9040;
        }
      ];
      DNSPort = [
        {
          addr = "127.0.0.1";
          port = 5353;
        }
      ];
      ControlPort = [
        {
          addr = "127.0.0.1";
          port = 9051;
        }
      ];
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

  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      factor = "2";
      maxtime = "12h";
      overalljails = true;
    };
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ];
    jails = {
      sshd = {
        settings = {
          enabled = true;
          port = "ssh";
          filter = "sshd";
          maxretry = 3;
          bantime = "1h";
          findtime = "10m";
        };
      };
    };
  };

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
    path = with pkgs; [
      iproute2
      iptables
    ];
    serviceConfig.Type = "simple";
    serviceConfig.Restart = "always";
    serviceConfig.RestartSec = 3;
    script = ''
      # Create chain
      iptables -N PROTON_KS 2>/dev/null || iptables -F PROTON_KS

      # Phase 1: pre-connection — allow VPN handshake but block everything else
      iptables -A PROTON_KS -o lo -j ACCEPT
      iptables -A PROTON_KS -p udp --dport 53 -j ACCEPT
      iptables -A PROTON_KS -p tcp --dport 53 -j ACCEPT
      iptables -A PROTON_KS -p udp --dport 123 -j ACCEPT
      iptables -A PROTON_KS -p udp --dport 443 -j ACCEPT
      iptables -A PROTON_KS -p tcp --dport 443 -j ACCEPT
      iptables -A PROTON_KS -m state --state ESTABLISHED,RELATED -j ACCEPT
      iptables -A PROTON_KS -j DROP
      iptables -C OUTPUT -j PROTON_KS 2>/dev/null || iptables -A OUTPUT -j PROTON_KS

      ip6tables -P OUTPUT DROP 2>/dev/null || true

      # Poll for proton0: tighten when up, loosen when down
      while true; do
        if ip link show proton0 >/dev/null 2>&1; then
          # Phase 2: VPN connected — ONLY allow traffic through proton0
          iptables -C PROTON_KS -o proton0 -j ACCEPT 2>/dev/null || iptables -I PROTON_KS 7 -o proton0 -j ACCEPT
          iptables -D PROTON_KS -p udp --dport 443 -j ACCEPT 2>/dev/null || true
          iptables -D PROTON_KS -p tcp --dport 443 -j ACCEPT 2>/dev/null || true
        else
          # Phase 1: VPN disconnected — re-allow handshake
          iptables -D PROTON_KS -o proton0 -j ACCEPT 2>/dev/null || true
          iptables -C PROTON_KS -p udp --dport 443 -j ACCEPT 2>/dev/null || iptables -I PROTON_KS 6 -p udp --dport 443 -j ACCEPT
          iptables -C PROTON_KS -p tcp --dport 443 -j ACCEPT 2>/dev/null || iptables -I PROTON_KS 7 -p tcp --dport 443 -j ACCEPT
        fi
        sleep 5
      done
    '';
    preStop = ''
      iptables -D OUTPUT -j PROTON_KS 2>/dev/null || true
      iptables -F PROTON_KS 2>/dev/null || true
      iptables -X PROTON_KS 2>/dev/null || true
      ip6tables -P OUTPUT ACCEPT 2>/dev/null || true
    '';
  };

  # tor-hardening: don't auto-start on gentuwu (Proton VPN is default).
  # Use `starttor` fish function to activate manually when needed.
  systemd.services.tor-hardening.wantedBy = lib.mkForce [ ];

  # Cloudflare WARP: MASQUE/QUIC protocol (looks like HTTPS to DPI).
  # Use `warp-on`/`warp-off` fish functions to toggle.
  # Do NOT run alongside ProtonVPN — use one or the other.
  # Pre-resolve API endpoint to avoid DNS timeout at daemon startup
  # (hickory-resolver used by the daemon sometimes fails under systemd-resolved).
  networking.extraHosts = ''
    104.16.192.82 api.cloudflareclient.com
    104.16.24.84 api.cloudflareclient.com
    # Anycast include/exclude IPs from WARP policy
    162.159.197.4
    2606:4700:102::4
    162.159.197.3
    2606:4700:102::3
  '';
  services.cloudflare-warp = {
    enable = true;
    openFirewall = true;
  };

  systemd.tmpfiles.rules = [
    "L+ /usr/sbin/nft - - - - ${pkgs.nftables}/bin/nft"
  ];
}
