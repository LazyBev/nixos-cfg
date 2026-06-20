{ config, lib, ... }: let
  isSecbox = builtins.elem config.vars.hostname [ "secbox" "secbox-laptop" ];
in lib.mkIf isSecbox {

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.macAddress = "random";
  networking.networkmanager.ethernet.macAddress = "random";
  networking.firewall.enable = true;
  networking.firewall.logRefusedConnections = true;
  networking.enableIPv6 = false;

  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.firewall.allowedTCPPorts = [ 22 8080 8443 9050 9051 ];
  networking.firewall.allowedUDPPorts = [ 51820 ];
  networking.firewall.allowPing = false;
  networking.firewall.checkReversePath = true;

  services.tor = {
    enable = true;
    client.enable = true;
    relay.enable = false;
    settings = {
      DNSPort = [{ addr = "127.0.0.1"; port = 5353; }];
      TransPort = [{ addr = "127.0.0.1"; port = 9040; }];
      VirtualAddrNetwork = "10.192.0.0/10";
      AutomapHostsOnResolve = true;
    };
  };

  services.resolved.enable = true;
  services.resolved.settings = {
    Resolve.DNSSEC = "true";
    Resolve.FallbackDNS = "1.1.1.1 1.0.0.1";
    Resolve.DNS = "127.0.0.1 5353";
  };

  boot.kernelParams = [
    "audit=1"
    "audit_backlog_limit=8192"
    "module.sig_enforce=1"
    "lockdown=confidentiality"
    "slab_nomerge"
    "init_on_alloc=1"
    "init_on_free=1"
    "page_alloc.shuffle=1"
  ];

  security.lockKernelModules = true;
  security.protectKernelImage = true;
  security.forcePageTableIsolation = true;
  security.virtualisation.flushL1DataCache = "always";

  boot.kernel.sysctl = {
    "kernel.unprivileged_userns_clone" = 0;
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.perf_event_paranoid" = 3;
    "kernel.yama.ptrace_scope" = 1;
    "kernel.randomize_va_space" = 2;
    "kernel.exec-shield" = 1;
    "kernel.ftrace_enabled" = false;
    "kernel.unprivileged_bpf_disabled" = 1;
    "kernel.io_uring_disabled" = 2;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.log_martians" = true;
    "net.ipv4.conf.default.log_martians" = true;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.ip_forward" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
  };

  boot.blacklistedKernelModules = [
    "dccp" "sctp" "rds" "tipc"
    "bluetooth" "btusb" "btintel"
    "uvcvideo" "pwc"
    "joydev"
    "pcspkr"
    "snd_hda_intel"
    "snd_hda_codec_hdmi"
    "snd_usb_audio"
    "thunderbolt"
    "firewire_ohci"
    "firewire_core"
    "nouveau"
    "radeon"
  ];

  hardware.bluetooth.enable = false;
  hardware.enableAllFirmware = false;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.X11Forwarding = false;
  services.openssh.settings.AllowAgentForwarding = false;
  services.openssh.settings.MaxAuthTries = 3;

  services.fail2ban.enable = true;
  services.clamav.updater.enable = true;
  services.avahi.enable = false;
  services.geoclue2.enable = false;

  systemd.coredump.enable = false;
  boot.kernel.sysctl."kernel.core_pattern" = "|/bin/false";

  environment.sessionVariables = {
    PENTEST_HOME = "/home/pentest";
    EDITOR = "nvim";
    SHELL = "/run/current-system/sw/bin/zsh";
    TOR_PORT = "9050";
    ALL_PROXY = "socks5://127.0.0.1:9050";
    http_proxy = "";
    https_proxy = "";
  };

  programs.bash.interactiveShellInit = ''
    export PS1="\[\e[31m\][\u@\h \w]\\$\[\e[0m\] "
  '';

  services.logind.settings = {
    Login = {
      HandlePowerKey = "poweroff";
      HandleSuspendKey = "ignore";
      HandleHibernateKey = "ignore";
      HandleLidSwitch = "ignore";
      IdleAction = "lock";
      IdleActionSec = "5min";
    };
  };
}
