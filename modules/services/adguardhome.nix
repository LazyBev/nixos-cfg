{ ... }: {
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    mutableSettings = true;
    settings = {
      schema_version = 22;
      dns.port = 53;
    };
  };
}
