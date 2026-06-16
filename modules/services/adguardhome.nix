{ ... }: {
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 8080;
    mutableSettings = true;
    settings = {
      schema_version = 22;
      dns = {
        port = 53;
        upstream_dns = [
          "https://dns.quad9.net/dns-query"
          "https://dns.cloudflare.com/dns-query"
        ];
        upstream_dns_file = "";
        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
        ];
        fallback_dns = [
          "https://dns.cloudflare.com/dns-query"
        ];
      };
    };
  };
}
