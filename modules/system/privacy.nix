{ pkgs, lib, ... }: {
  services.geoclue2.enable = false;
  services.avahi.enable = false;
  hardware.bluetooth.enable = false;

  boot.kernelParams = [
    "iommu=force"
    "iommu.passthrough=0"
    "iommu.strict=1"
    "mitigations=auto"
  ];

  systemd.coredump.enable = false;

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      signal-desktop = {
        executable = "${lib.getBin pkgs.signal-desktop}/bin/signal-desktop";
        profile = "${pkgs.firejail}/etc/firejail/signal-desktop.profile";
        extraArgs = [
          "--env=GTK_THEME=Adwaita:dark"
          "--dbus-user.talk=org.kde.StatusNotifierWatcher"
        ];
      };
      vesktop = {
        executable = "${lib.getBin pkgs.vesktop}/bin/vesktop";
        profile = "${pkgs.firejail}/etc/firejail/vesktop.profile";
        extraArgs = [
          "--env=NIXOS_OZONE_WL=1"
          "--dbus-user.talk=org.kde.StatusNotifierWatcher"
        ];
      };
    };
  };

  # Extra Firejail config for LibreWolf (U2F USB key support)
  environment.etc."firejail/librewolf.local".text = ''
    ignore private-dev
  '';

  system.activationScripts.firejail = ''
    ${pkgs.firejail}/bin/firecfg
  '';
}
