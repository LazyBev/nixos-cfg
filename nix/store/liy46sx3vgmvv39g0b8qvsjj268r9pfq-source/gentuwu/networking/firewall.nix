_: {
  networking.firewall = {
    enable = true;
    logRefusedConnections = false;
    allowPing = false;
    checkReversePath = "loose";
  };
}
