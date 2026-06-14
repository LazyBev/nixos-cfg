{ ... }: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = false;
    dedicatedServer.openFirewall = false;
  };
  hardware.steam-hardware.enable = true;
}
