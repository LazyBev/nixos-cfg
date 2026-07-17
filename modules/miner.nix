{ config, lib, pkgs, ... }: {
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };
  users.users.yari.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnSiJZsEbeNvZzhstYIWVVA9jNWKBSvLaxE6qeN6+iZ yari@gentuwu"
  ];
  console.keyMap = "uk";
  programs.fish.enable = true;
  security.doas = {
    enable = true;
    extraRules = [{ groups = [ "wheel" ]; persist = true; keepEnv = true; }];
  };
  security.sudo.wheelNeedsPassword = false;
  networking.networkmanager.enable = true;
  system.stateVersion = "25.05";
}
