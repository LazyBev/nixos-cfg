{
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    mutableSettings = true;
    settings = {
      schema_version = 22;
      dns = {
        port = 53;
        bind_hosts = [ "127.0.0.1" ];
        upstream_dns = [
          "https://dns.adguard-dns.com/dns-query"
          "https://dns.quad9.net/dns-query"
        ];
        upstream_dns_file = "";
        bootstrap_dns = [
          "94.140.14.14"
          "9.9.9.9"
        ];
        fallback_dns = [ "https://dns.adguard-dns.com/dns-query" ];
      };
    };
  };
}
