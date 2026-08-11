_: {
  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "true";
      LLMNR = "false";
      MulticastDNS = "false";
      FallbackDNS = "1.1.1.1 1.0.0.1";
    };
  };
}
