_: {
  security = {
    lockKernelModules = true;
    forcePageTableIsolation = true;
  };
  services = {
    geoclue2.enable = false;
    avahi.enable = false;
  };
}
