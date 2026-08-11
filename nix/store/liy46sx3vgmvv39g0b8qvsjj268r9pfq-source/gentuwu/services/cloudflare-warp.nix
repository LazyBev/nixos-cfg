{
  networking.extraHosts = ''
    104.16.192.82 api.cloudflareclient.com
    104.16.24.84 api.cloudflareclient.com
    162.159.197.4
    2606:4700:102::4
    162.159.197.3
    2606:4700:102::3
  '';
  services.cloudflare-warp = {
    enable = true;
    openFirewall = true;
  };
}
