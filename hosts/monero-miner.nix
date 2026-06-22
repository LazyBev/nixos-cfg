{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/users/yari.nix
    ../modules/programs/monerod.nix
    ../modules/programs/p2pool.nix
    ./hardware-configuration-monero-miner.nix
  ];

  services.monerod.enable = true;

  services.p2pool = {
    enable = true;
    chain = "nano";
    wallet = "48a3TZTm3yGB4HnWm3fkxBPitoeBgSC1NVHPGaLsFSD7GA195RAYGEufyJk6uzgg2Jd5uUrJXo1Py1ru5xBMfG51H5YC69c";
    extraArgs = [ "--light-mode" ];
  };

  networking.hostName = "monero-miner";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  boot.kernelParams = [
    "mitigations=off"
    "nmi_watchdog=0"
    "nowatchdog"
  ];

  boot.kernelModules = [ "msr" ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  boot.kernel.sysctl = {
    "vm.nr_hugepages" = 1280;
    "vm.max_map_count" = 262144;
    "kernel.timer_migration" = 0;
    "kernel.nmi_watchdog" = 0;
  };

  environment.systemPackages = with pkgs; [
    xmrig
    monero-cli
    git
    just
    nh
    vim
  ];

  environment.etc."xmrig/config.json".source = ../configs/xmrig/config.json;

  systemd.services.xmrig = {
    description = "Monero miner";
    after = [ "sys-devices-virtual-misc-hugepages.device" "p2pool.service" ];
    wants = [ "p2pool.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.xmrig}/bin/xmrig --config=/etc/xmrig/config.json";
      Restart = "on-failure";
      Nice = -20;
      IOSchedulingClass = "realtime";
      CPUSchedulingPolicy = "fifo";
      CPUSchedulingPriority = 99;
      LimitMEMLOCK = "infinity";
    };
  };

  networking.firewall.allowedTCPPorts = [ 3333 37890 18081 ];
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
