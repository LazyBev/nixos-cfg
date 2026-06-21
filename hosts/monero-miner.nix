{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/users/yari.nix
    ./hardware-configuration-monero-miner.nix
  ];

  networking.hostName = "monero-miner";

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "mitigations=off"
    "nmi_watchdog=0"
    "nowatchdog"
  ];

  boot.kernelModules = [ "msr" ];

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
  ];

  environment.etc."xmrig/config.json".source = ../configs/xmrig/config.json;

  systemd.services.xmrig = {
    description = "Monero miner";
    after = [ "sys-devices-virtual-misc-hugepages.device" ];
    wantedBy = [ "multi-user.target" ];
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

  services.openssh.enable = true;

  programs.fish.enable = true;

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
