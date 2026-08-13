_: {
  boot.loader = {
    grub = {
      enable = false;
    };
    timeout = 5;
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = false;
    limine = {
      enable = true;
      efiSupport = true;
    };
  };
}
