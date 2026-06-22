{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/users/yari.nix
  ];

  networking.hostName = "worker-opti";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    xmrig
    git
    just
    nh
    vim
  ];

  environment.etc."xmrig/config.json".source = ../configs/xmrig/config-worker-opti.json;

  systemd.services.xmrig = {
    description = "Monero miner";
    serviceConfig = {
      ExecStart = "${pkgs.xmrig}/bin/xmrig --config=/etc/xmrig/config.json";
      Restart = "on-failure";
    };
  };

  networking.networkmanager.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;

  users.users.yari.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnSiJZsEbeNvZzhstYIWVVA9jNWKBSvLaxE6qeN6+iZ yari@gentuwu"
  ];

  console.keyMap = "uk";

  programs.fish.enable = true;

  security.doas.enable = true;
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    persist = true;
    keepEnv = true;
  }];
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
