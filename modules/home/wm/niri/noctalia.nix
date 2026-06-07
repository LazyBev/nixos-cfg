{ inputs, ... }: {
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      settings = 
        (builtins.fromJSON
          (builtins.readFile ../../../../configs/apps/noctalia/noctalia.json)).settings;
    };
  };
}
