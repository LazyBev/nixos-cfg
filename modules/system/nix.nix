{ config, nix-cachyos-kernel, ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 6;
    build-cores = 0;
    max-substitution-jobs = 16;
    keep-going = true;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    trusted-substituters = [
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
    ];
  };
  nixpkgs.overlays = [
    nix-cachyos-kernel.overlays.default
    (import ../../overlays/caelus-theme.nix)
    (import ../../overlays/beaker.nix)
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
