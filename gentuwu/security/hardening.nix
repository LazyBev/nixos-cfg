_: {
  boot.kernel.sysctl = {
    "fs.suid_dumpable" = 0;
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.perf_event_paranoid" = 3;
    "kernel.kexec_load_disabled" = 1;
    "kernel.unprivileged_bpf_disabled" = 1;
    "net.core.bpf_jit_harden" = 2;
    # Low-risk exploitation-surface cuts on top of the cmdline hardening in
    # boot/kernel.nix (kernel cmdline already covers init_on_*, slab_nomerge,
    # pti, page_poison, vsyscall=none, debugfs=off).
    "vm.mmap_min_addr" = 65536; # NULL-page mapping denied
    "vm.unprivileged_userfaultfd" = 0; # deny the classic state-confusion gadget
  };
}
