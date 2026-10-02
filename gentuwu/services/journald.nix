_:
{
  services.journald.extraConfig = ''
    Seal=true
    Compress=true
    SystemMaxUse=256M
    SystemMaxFileSize=64M
    MaxRetentionSec=2month
  '';
}