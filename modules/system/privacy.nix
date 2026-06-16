{ pkgs, lib, ... }: {
  services.geoclue2.enable = false;
  services.avahi.enable = false;
  hardware.bluetooth.enable = false;

  boot.kernelParams = [
    "iommu=force"
    "iommu.passthrough=0"
    "iommu.strict=1"
    "mitigations=auto"
  ];

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = "2";
    "kernel.dmesg_restrict" = "1";
    "kernel.printk" = "3 3 3 3";
    "kernel.unprivileged_bpf_disabled" = "1";
    "net.core.bpf_jit_harden" = "2";
    "dev.tty.ldisc_autoload" = "0";
    "vm.unprivileged_userfaultfd" = "0";
    "kernel.kexec_load_disabled" = "1";
    "kernel.sysrq" = "0";
    "kernel.unprivileged_userns_clone" = "1";
    "net.ipv4.tcp_syncookies" = "1";
    "net.ipv4.tcp_rfc1337" = "1";
    "net.ipv4.conf.all.rp_filter" = "1";
    "net.ipv4.conf.default.rp_filter" = "1";
    "net.ipv4.conf.all.accept_redirects" = "0";
    "net.ipv4.conf.default.accept_redirects" = "0";
    "net.ipv4.conf.all.secure_redirects" = "0";
    "net.ipv4.conf.default.secure_redirects" = "0";
    "net.ipv6.conf.all.accept_redirects" = "0";
    "net.ipv6.conf.default.accept_redirects" = "0";
    "net.ipv4.conf.all.send_redirects" = "0";
    "net.ipv4.conf.default.send_redirects" = "0";
    "net.ipv6.conf.all.accept_ra" = "0";
    "net.ipv6.conf.default.accept_ra" = "0";
    "net.ipv4.tcp_sack" = "0";
    "net.ipv4.tcp_dsack" = "0";
    "net.ipv4.tcp_fack" = "0";
    "net.ipv4.tcp_timestamps" = "0";
  };

  systemd.coredump.enable = false;

  programs.firejail.enable = true;

  system.activationScripts.firejail = ''
    ${pkgs.firejail}/bin/firecfg
  '';
}
