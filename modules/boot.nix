{ config, pkgs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [ config.boot.kernelPackages.msi-ec ];

    initrd = {
      availableKernelModules = [
        "ahci"
        "usbhid"
      ];
      emergencyAccess = true;
    };

    loader.efi.canTouchEfiVariables = true;

    kernelModules = [
      "fuse"
      "msi-ec"
    ];

    kernelParams = [
      "init_on_alloc=1"
      "init_on_free=1"
      "slab_nomerge"
      "pti=on"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      "vsyscall=none"
      "debugfs=off"
      "quiet"
    ];
  };

  programs.plymouth.enable = true;

  programs.modprobe.blacklist = [
    "dccp"
    "sctp"
    "rds"
    "tipc"
  ];

  finit.runlevel = 3;
}
