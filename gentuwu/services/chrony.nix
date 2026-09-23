_: {
  # Chrony with Network Time Security (RFC 8915): time sync protected by
  # certificate-authenticated TLS over UDP 4460. An attacker who can only
  # spoof/roll plain NTP can quietly skew the clock and break TLS-validity
  # checks — NTS closes that. All three servers expose NTS.
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      "time.cloudflare.com"
      "time.google.com"
      "time.nist.gov"
    ];
  };
}
