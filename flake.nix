{
  description = "gentuwu's finix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    finix.url = "github:finix-community/finix";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
<<<<<<< HEAD
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };
    omnisearch = {
      url = "git+https://git.bwaaa.monster/omnisearch?rev=9c68a8ae6fb32f8a1660da392b9985a4ab3e7cb4&shallow=0";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
=======
    hjem-rum = {
      url = "github:snugnug/hjem-rum";
>>>>>>> 84a8250 (New config)
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nirimod = {
      url = "github:srinivasr/nirimod";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:4evy/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      finix,
      hjem,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = import ./overlays.nix;
        config = {
          allowUnfree = true;
          joypixels.acceptLicense = true;
          permittedInsecurePackages = [
            "electron-39.8.10"
            "librewolf-151.0.2-1"
            "librewolf-unwrapped-151.0.2-1"
            "pnpm-10.29.2"
          ];
        };
      };
    in
    {
      nixosConfigurations.gentuwu = finix.lib.finixSystem {
        inherit (pkgs) lib;
        modules = [
          { nixpkgs.pkgs = pkgs; }
          { _module.args = { inherit inputs; }; }
          hjem.finixModules.default
          ./hosts/gentuwu
        ]
        ++ builtins.attrValues finix.nixosModules;
      };
    };
}
