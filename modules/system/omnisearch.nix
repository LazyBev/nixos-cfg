{ pkgs, ... }: {
  nixpkgs.overlays = [
    (self: super: {
      omnisearch = super.omnisearch.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.git ];
        postPatch = (old.postPatch or "") + ''
          substituteInPlace beaker/call.py --replace-fail "beaker_get_header()" "'localhost'"
        '';
      });
    })
  ];

  services.omnisearch = {
    enable = true;
    package = pkgs.omnisearch;
    settings = {
      server = {
        domain = "http://localhost:8087";
      };
    };
  };
}
