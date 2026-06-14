{
  description = "gentuwu's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf = {
      url = "github:notashelf/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, hjem, nvf }: let
    mkSystem = host: extraModules: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        hjem.nixosModules.default
        nvf.nixosModules.default
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
