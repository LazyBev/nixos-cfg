{ config, ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = config.vars.maxJobs;
    max-substitution-jobs = 5;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    allowed-users = [ "root" "@users" ];
  };
  nixpkgs.overlays = [
    (import ../../overlays/caelus-theme.nix)
    (import ../../overlays/dracula-theme.nix)
    (import ../../overlays/pragmasevka.nix)
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
  system.autoUpgrade = {
    enable = false;
    allowReboot = false;
  };
}
