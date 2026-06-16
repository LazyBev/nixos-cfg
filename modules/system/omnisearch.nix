{ pkgs, omnisearch, ... }: {
  services.omnisearch = {
    enable = true;
    package = omnisearch.packages.x86_64-linux.default.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.git ];
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
