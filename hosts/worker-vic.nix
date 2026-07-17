{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/miner.nix
    ../modules/users/yari.nix
    ../modules/services.nix
    ./hardware-configuration-worker-vic.nix
  ];

  networking.hostName = "worker-vic";

  services.monerod.enable = true;

  services.p2pool = {
    enable = true;
    chain = "nano";
    wallet = "48a3TZTm3yGB4HnWm3fkxBPitoeBgSC1NVHPGaLsFSD7GA195RAYGEufyJk6uzgg2Jd5uUrJXo1Py1ru5xBMfG51H5YC69c";
    extraArgs = [ "--light-mode" ];
  };

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
    git
    just
    nh
    vim
  ];
  environment.etc."xmrig/config.json".source = ../dotfiles/xmrig/config-worker-vic.json;

  systemd.services.xmrig = {
    description = "Monero miner";
    after = [ "sys-devices-virtual-misc-hugepages.device" "p2pool.service" ];
    wants = [ "p2pool.service" ];
    serviceConfig = {
      ExecStart = "${pkgs.xmrig}/bin/xmrig --config=/etc/xmrig/config.json";
      Restart = "on-failure";
      LimitMEMLOCK = "infinity";
    };
  };

  networking.firewall.allowedTCPPorts = [ 3333 37890 18081 ];
}
