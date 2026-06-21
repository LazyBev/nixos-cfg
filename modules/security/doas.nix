{ config, lib, ... }: {
  security.doas.enable = true;
  security.sudo.enable = true;
  security.sudo.wheelNeedsPassword = false;
  security.doas.extraRules = [{
    groups = [ "wheel" ];
    persist = true;
    keepEnv = true;
  }];
}
