{ pkgs, ... }: {
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.timeout = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = false;
  boot.loader.limine.enable = false;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "quiet"
    "systemd.show_status=error"
  ];
  boot.plymouth.enable = true;
  boot.plymouth.theme = "spinner";
}
