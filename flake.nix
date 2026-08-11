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
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=latest";
    };
    omnisearch = {
      url = "git+https://git.bwaaa.monster/omnisearch?rev=9c68a8ae6fb32f8a1660da392b9985a4ab3e7cb4";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nirimod = {
      url = "github:srinivasr/nirimod";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, lib, ... }:
      let
        isNix = f: lib.hasSuffix ".nix" f;
        hostModules = builtins.filter isNix (nixpkgs.lib.filesystem.listFilesRecursive ./gentuwu);
        homeModules = builtins.filter isNix (nixpkgs.lib.filesystem.listFilesRecursive ./yari);
      in
      {
        imports = [
          inputs.easy-hosts.flakeModule
        ];

        config = {
          systems = [ "x86_64-linux" ];

          perSystem = { pkgs, ... }: {
            formatter = pkgs.nixfmt;
          };

          easy-hosts = {
            useGlobalPkgs = false;

            shared = {
              modules = [ ];
              specialArgs = {
                inherit inputs;
                inherit (inputs)
                  omnisearch
                  stylix
                  noctalia
                  ;
              };
            };

            hosts = {
              gentuwu = {
                arch = "x86_64";
                class = "nixos";
                deployable = true;
                modules = [
                  {
                    _module.args = {
                      inherit inputs;
                      inherit (inputs) omnisearch;
                    };
                  }
                  inputs.niri-nix.nixosModules.default
                  inputs.hjem.nixosModules.default
                  inputs.nix-flatpak.nixosModules.nix-flatpak
                  inputs.omnisearch.nixosModules.default
                  inputs.stylix.nixosModules.stylix
                  inputs.noctalia.nixosModules.default
                ]
                ++ hostModules
                ++ homeModules;
              };
            };
          };
        };
      }
    );
}
