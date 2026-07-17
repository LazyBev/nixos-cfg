{ lib, ... }: {
  imports = [
    ./niri.nix
    ./portal.nix
    ./sddm.nix
    ./opengl.nix
    ./pipewire.nix
    ./power.nix
    ./stylix.nix
    ./home.nix
    ./services.nix
    ./security.nix

    ./programs/atuin.nix
    ./programs/direnv.nix
    ./programs/fish.nix
    ./programs/git.nix
    ./programs/librewolf.nix
    ./programs/starship.nix
    ./programs/steam.nix

    ./system/boot.nix
    ./system/environment.nix
    ./system/fonts.nix
    ./system/locale.nix
    ./system/network.nix
    ./system/nix.nix
    ./system/omnisearch.nix
    ./system/vars.nix
    ./system/virtualisation.nix

    ./users/pentest.nix
    ./users/yari.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
    permittedInsecurePackages = [
      "electron-39.8.10"
      "librewolf-151.0.2-1"
      "librewolf-unwrapped-151.0.2-1"
      "pnpm-10.29.2"
    ];
    joypixels.acceptLicense = true;
  };

  nixpkgs.overlays = [
    (final: prev: {
      cpplint = prev.cpplint.overridePythonAttrs (_: {
        doCheck = false;
        doInstallCheck = false;
      });
    })
  ];
}
