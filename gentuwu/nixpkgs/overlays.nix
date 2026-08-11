_: {
  nixpkgs.overlays = [
    (final: prev: {
      cpplint = prev.cpplint.overridePythonAttrs (_: {
        doCheck = false;
        doInstallCheck = false;
      });
    })
  ];
}
