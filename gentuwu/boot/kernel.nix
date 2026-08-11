{
  pkgs,
  ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

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
