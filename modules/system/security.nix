{ lib, ... }: {
  boot.kernelParams = [
    "init_on_alloc=1"
    "init_on_free=1"
    "page_alloc.shuffle=1"
    "slab_nomerge"
    "randomize_kstack_offset=on"
    "pti=on"
    "vsyscall=none"
  ];

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
  };

  security.protectKernelImage = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };
}
