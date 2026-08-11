_: {
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-39.8.10"
      "librewolf-151.0.2-1"
      "librewolf-unwrapped-151.0.2-1"
      "pnpm-10.29.2"
    ];
    joypixels.acceptLicense = true;
  };
}
