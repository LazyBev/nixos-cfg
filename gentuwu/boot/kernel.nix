{
  pkgs,
  ...
}:
{
  boot = {
    # 7.2.2 (linuxPackages_latest) ships without nf_nat_masquerade anywhere in
    # its module closure — a 7.x mainline regression that kills NAT for
    # waydroid (waydroid0 MASQUERADE), since the module simply is not built.
    # Move to the stable branch where nf_nat_masquerade is present, letting
    # waydroid + the netVM domains use stock Masquerade with no snat shims.
    kernelPackages = pkgs.linuxPackages;

    kernelParams = [
      "init_on_alloc=1"
      "init_on_free=1"
      "slab_nomerge"
      "pti=on"
      "page_poison=1"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      "vsyscall=none"
      "debugfs=off"
      "quiet"
      "systemd.show_status=error"
    ];

    blacklistedKernelModules = [
      "dccp"
      "sctp"
      "rds"
      "tipc"
    ];
  };
}
