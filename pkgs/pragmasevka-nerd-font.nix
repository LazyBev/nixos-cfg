{
  stdenvNoCC,
  fetchurl,
  unzip,
}:
stdenvNoCC.mkDerivation {
  pname = "pragmasevka-nerd-font";
  version = "1.7.0";

  src = fetchurl {
    url = "https://github.com/shytikov/pragmasevka/releases/download/v1.7.0/Pragmasevka_NF.zip";
    hash = "sha256-7qt1jv9WLRyu12EkRIjlZUW+Jegaa0DNhLMbAyo3YVw=";
  };

  nativeBuildInputs = [ unzip ];
  unpackPhase = "unzip $src -d pragmasevka";
  installPhase = ''
    install -Dm644 pragmasevka/*.ttf -t $out/share/fonts/truetype
  '';

  meta.description = "Pragmasevka Nerd Font (PragmataPro look-alike from Iosevka)";
}
