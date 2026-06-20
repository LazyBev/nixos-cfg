{
  description = "gentuwu's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    easy-hosts.url = "github:tgirlcloud/easy-hosts";
    niri-nix = {
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };
    omnisearch = {
      url = "git+https://git.bwaaa.monster/omnisearch";
    };
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.easy-hosts.flakeModule ];

      systems = [ "x86_64-linux" ];

      easy-hosts = {
        useGlobalPkgs = false;

        shared = {
          modules = [
            inputs.niri-nix.nixosModules.default
            inputs.hjem.nixosModules.default
            inputs.nvf.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.omnisearch.nixosModules.default
            ./modules
          ];

          specialArgs = {
            inherit inputs;
            inherit (inputs)
              omnisearch
              ;
          };
        };

        hosts = {
          gentuwu = {
            arch = "x86_64";
            class = "nixos";
            deployable = true;
            tags = [ "desktop" ];
            modules = [ ./hosts/gentuwu-desktop.nix ];
          };

          gentuwu-laptop = {
            arch = "x86_64";
            class = "nixos";
            deployable = true;
            tags = [ "laptop" ];
            modules = [ ./hosts/gentuwu-laptop.nix ];
          };

          secbox = {
            arch = "x86_64";
            class = "nixos";
            deployable = true;
            tags = [ "security" "pentest" "desktop" ];
            modules = [ ./hosts/secbox.nix ];
          };

          secbox-laptop = {
            arch = "x86_64";
            class = "nixos";
            deployable = true;
            tags = [ "security" "pentest" "laptop" ];
            modules = [ ./hosts/secbox-laptop.nix ];
          };
        };
      };
    };
}
