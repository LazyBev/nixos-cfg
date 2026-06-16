{ pkgs, ... }: let
  fetch = pkgs.stdenv.mkDerivation {
    pname = "fetch";
    version = "2.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "areofyl";
      repo = "fetch";
      rev = "v2.1.0";
      hash = "sha256-9ixx7XJcY4ktcN/lUfjvFljvHIEO2ktOebeGgL0ulHg=";
    };
    makeFlags = [ "PREFIX=${placeholder "out"}" ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postInstall = ''
      wrapProgram $out/bin/fetch \
        --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.fastfetch pkgs.pciutils ]}
    '';
    meta.mainProgram = "fetch";
  };
in {
  hjem.users.yari.packages = [ fetch ];
}
