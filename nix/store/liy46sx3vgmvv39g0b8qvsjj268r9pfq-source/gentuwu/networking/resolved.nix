_: {
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      FallbackDNS = "1.1.1.1 1.0.0.1";
    };
  };
}
