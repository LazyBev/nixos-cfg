{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  lib,
  fastfetch,
  pciutils,
}:
stdenv.mkDerivation {
  pname = "fetch";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "areofyl";
    repo = "fetch";
    rev = "v2.1.0";
    hash = "sha256-9ixx7XJcY4ktcN/lUfjvFljvHIEO2ktOebeGgL0ulHg=";
  };

  nativeBuildInputs = [ makeWrapper ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postInstall = ''
    wrapProgram $out/bin/fetch --prefix PATH : ${
      lib.makeBinPath [
        fastfetch
        pciutils
      ]
    }
  '';

  meta.mainProgram = "fetch";
}
