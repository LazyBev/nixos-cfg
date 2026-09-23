_: {
  # Forward-secure sealing: journald tags every entry with a keyed MAC (FSS),
  # so after rotation nobody — not even root — can rewrite past log lines
  # unnoticed. The size caps keep logs from filling /var (also: the finer the
  # log granularity kept around, the more it's worth bounding).
  services.journald.extraConfig = ''
    Seal=yes
    Compress=yes
    SystemMaxUse=256M
    SystemMaxFileSize=64M
    MaxRetentionSec=2month
  '';
}
