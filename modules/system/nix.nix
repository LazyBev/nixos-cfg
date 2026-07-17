{ config, inputs, ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "yari" ];
    max-jobs = 6;
    build-cores = 6;
    max-substitution-jobs = 16;
    keep-going = true;
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Zm5IX6hLuM="
    ];
    trusted-substituters = [
      "https://attic.xuyh0120.win/lantian"
      "https://cache.garnix.io"
    ];
  };
  nixpkgs.overlays = [
    (final: prev: let
      beaker-src = builtins.fetchGit {
        url = "https://git.bwaaa.monster/beaker";
        rev = "3fab89ecf8f4c664477a82add660d28db87357b4";
      };
    in {
      beaker = prev.stdenv.mkDerivation {
        pname = "beaker";
        version = "git";
        src = beaker-src;
        makeFlags = [ "INSTALL_PREFIX=$(out)/" "LDCONFIG=true" ];
      };
    })
    (final: prev: {
      pragmasevka-nerd-font = prev.stdenvNoCC.mkDerivation {
        pname = "pragmasevka-nerd-font";
        version = "1.7.0";
        src = prev.fetchurl {
          url = "https://github.com/shytikov/pragmasevka/releases/download/v1.7.0/Pragmasevka_NF.zip";
          hash = "sha256-7qt1jv9WLRyu12EkRIjlZUW+Jegaa0DNhLMbAyo3YVw=";
        };
        nativeBuildInputs = [ prev.unzip ];
        unpackPhase = "unzip $src -d pragmasevka";
        installPhase = ''
          mkdir -p $out/share/fonts/truetype
          cp pragmasevka/*.ttf $out/share/fonts/truetype/
        '';
        meta.description = "Pragmasevka Nerd Font (PragmataPro doppelgänger from Iosevka)";
      };
    })
    inputs.ribbon.overlays.default
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
