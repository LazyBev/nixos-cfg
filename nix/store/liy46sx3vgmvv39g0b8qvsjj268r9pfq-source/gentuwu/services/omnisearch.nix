{ pkgs, inputs, ... }: {
  services.omnisearch = {
    enable = true;
    package = inputs.omnisearch.packages.${pkgs.system}.default.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.git ];
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/Main.c --replace-fail "beaker_get_header(\"Host\")" '"localhost"'
      '';
    });
    settings = {
      server = {
        domain = "http://localhost:8087";
      };
    };
  };
}
