{pkgs, ...}: {
  boot.loader.systemd-boot.configurationLimit = null;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 5;
  boot.loader.systemd-boot.editor = false;
  boot.loader.grub.enable = false;
  boot.loader.limine.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "quiet"
    "systemd.show_status=error"
  ];
  boot.plymouth.enable = true;
}
