{
  description = "gentuwu's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omnisearch = {
      url = "git+https://git.bwaaa.monster/omnisearch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, niri-nix, hjem, nvf, nix-flatpak, omnisearch }: let
    mkSystem = host: extraModules: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        niri-nix.nixosModules.default
        hjem.nixosModules.default
        nvf.nixosModules.default
        nix-flatpak.nixosModules.nix-flatpak
        omnisearch.nixosModules.default
        ./modules
      ] ++ extraModules;
    };
  in {
    nixosConfigurations = {
      gentuwu = mkSystem "desktop" [ ./hosts/gentuwu-desktop.nix ];
      gentuwu-laptop = mkSystem "laptop" [ ./hosts/gentuwu-laptop.nix ];
    };
  };
}
