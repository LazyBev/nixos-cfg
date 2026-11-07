{
  config,
  lib,
  pkgs,
  ...
}:
let
  locale = "en_GB.UTF-8";
  password = "$y$j9T$QwDmcKYHAT2HFLNxsBmMy/$8ocpuTEentUo0lfkPwV8tuYYDovhcsRupPml/bOyrnA";
in
{
  time.timeZone = "Europe/London";

  i18n = {
    defaultLocale = locale;
    extraLocaleSettings = lib.genAttrs [
      "LC_ADDRESS"
      "LC_IDENTIFICATION"
      "LC_MEASUREMENT"
      "LC_MONETARY"
      "LC_NAME"
      "LC_NUMERIC"
      "LC_PAPER"
      "LC_TELEPHONE"
      "LC_TIME"
    ] (_: locale);
  };
  programs.xorg.xkb.layout = "gb";

  users = {
    defaultUserShell = pkgs.fish;
    users.root.password = password;
    users.yari = {
      isNormalUser = true;
      uid = 1000;
      description = "yari";
      shell = pkgs.fish;
      inherit password;
      extraGroups = [
        "wheel"
        "video"
        "input"
        "seat"
        "network"
      ];
    };
  };

  services.zram-swap = {
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;
    "vm.dirty_background_bytes" = 64 * 1024 * 1024;
    "vm.dirty_bytes" = 256 * 1024 * 1024;
    "vm.dirty_expire_centisecs" = 3000;
    "vm.dirty_writeback_centisecs" = 1500;
  };

  services.udev.packages = [
    (pkgs.writeTextDir "etc/udev/rules.d/60-nvme-scheduler.rules" ''
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    '')
  ];

  environment.systemPackages = [ config.boot.kernelPackages.cpupower ];

  finit.services.cronie = {
    description = "Cron daemon";
    runlevels = "2345";
    conditions = [ "service/syslogd/ready" ];
    command = "${pkgs.cronie}/bin/crond -n";
  };

  environment.etc = {
    "cron.d/btrfs-scrub".text = "@monthly root ${pkgs.btrfs-progs}/bin/btrfs scrub start -B /\n";
    "cron.d/fstrim".text = "@monthly root ${pkgs.util-linux}/bin/fstrim -av\n";
    "cron.d/nix-gc".text =
      "0 4 1 * * root ${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 30d\n";
  };
}
