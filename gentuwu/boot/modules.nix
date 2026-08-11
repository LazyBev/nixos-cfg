{
  config,
  ...
}:
{
  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "usbhid"
    ];

    extraModulePackages = with config.boot.kernelPackages; [ msi-ec ];

    kernelModules = [
      "kvm-amd"
      "kvm-intel"
      "fuse"
      "msi-ec"
      "nft_reject"
      "nf_reject_ipv4"
      "nf_reject_ipv6"
      "nft_reject_inet"
    ];
  };
}
