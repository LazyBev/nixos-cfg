{ pkgs, ... }: {
  boot.loader.grub.enable = false;
  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "quiet"
    "systemd.show_status=error"
  ];
  boot.plymouth.enable = true;
}
