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
        # 0.0.0.0 default in the omnisearch ini would expose the search server
        # to the whole LAN; this service only serves the local user.
        host = "127.0.0.1";
        domain = "http://localhost:8087";
      };
    };
  };
}
