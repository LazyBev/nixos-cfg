{ lib, ... }: {
  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = 3;
    "kernel.yama.ptrace_scope" = 2;
    "net.core.bpf_jit_enable" = 0;
    "net.ipv4.tcp_syncookies" = 1;
    "dev.tty.ldisc_autoload" = 0;
    "vm.mmap_rnd_bits" = 32;
    "vm.mmap_rnd_compat_bits" = 16;
  };
}
