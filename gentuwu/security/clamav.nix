{ pkgs, ... }: {
  services.clamav = {
    updater.enable = true;
    updater.interval = "hourly";
    daemon.enable = true;
    scanner = {
      enable = true;
      interval = "hourly";
      scanDirectories = [ "/home/yari/Downloads" ];
    };
  };

  systemd.paths.clamav-watch-downloads = {
    description = "Watch ~/Downloads for new files to scan";
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      PathChanged = "/home/yari/Downloads";
      Unit = "clamav-scan-download.service";
    };
  };
  systemd.services.clamav-scan-download = {
    description = "Scan new download with ClamAV";
    after = [ "clamav-daemon.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      OUTPUT=$(${pkgs.clamav}/bin/clamdscan --infected /home/yari/Downloads/ 2>&1)
      if echo "$OUTPUT" | grep -q "FOUND"; then
        ${pkgs.libnotify}/bin/notify-send -u critical "Malware detected!" "$(echo "$OUTPUT" | grep FOUND)"
      fi
    '';
  };
}
