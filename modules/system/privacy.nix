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

  systemd.coredump.enable = false;

  programs.firejail.enable = true;

  system.activationScripts.firejail = ''
    ${pkgs.firejail}/bin/firecfg
  '';
}
