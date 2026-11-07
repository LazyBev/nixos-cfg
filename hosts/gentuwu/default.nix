{ inputs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  networking.hostName = "gentuwu";

  hjem = {
    clobberByDefault = true;
    extraModules = [
      inputs.hjem-rum.hjemModules.default
      ../../hjem
    ];
    specialArgs = { inherit inputs; };
    users.yari = {
      enable = true;
      rum.environment.hideWarning = true;
    };
  };
}
