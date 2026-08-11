{ pkgs, ... }: {
  services.postgresql = {
    # Pin to the major version of the existing data dir (/var/lib/postgresql/16).
    package = pkgs.postgresql_16;
  };

  services.nextcloud = {
    enable = true;
    hostName = "192.168.1.200";
    package = pkgs.nextcloud33;
    https = false;
    database.createLocally = true;
    config.dbtype = "pgsql";
    config.adminuser = "yari";
    config.adminpassFile = "/etc/nextcloud-adminpass";
    configureRedis = true;
    autoUpdateApps.enable = false;
    maxUploadSize = "8G";
    settings = {
      trusted_domains = [
        "192.168.1.200"
        "gentuwu"
        "localhost"
      ];
      defaultPhoneRegion = "PT";
      appstoreEnable = false;
      "upgrade.disable-web" = true;
      overwrite.cli.url = "http://192.168.1.200";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];
}
