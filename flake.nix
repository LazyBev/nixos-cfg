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
      url = "https://git.bwaaa.monster/omnisearch/snapshot/master.tar.gz";
    };
  };

  outputs = inputs @ { flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.easy-hosts.flakeModule ];

      systems = [ "x86_64-linux" ];

      flake.nixosConfigurations.worker-vic = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/worker-vic.nix ];
      };

      flake.nixosConfigurations.worker-opti = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/worker-opti.nix ];
      };

      flake.nixosConfigurations.secbox = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/secbox.nix ];
      };

      flake.nixosConfigurations.secbox-laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/secbox-laptop.nix ];
      };

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


        };
      };
    };
}
