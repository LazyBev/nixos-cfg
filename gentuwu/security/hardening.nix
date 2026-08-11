_: {
  boot.kernel.sysctl = {
    "fs.suid_dumpable" = 0;
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.perf_event_paranoid" = 3;
    "kernel.kexec_load_disabled" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;
  };
}
