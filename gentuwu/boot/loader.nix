_: {
  boot.loader = {
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
    timeout = 5;
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = false;
    limine.enable = false;
  };
}
