final: prev: {
  pragmasevka-nerd-font = prev.stdenvNoCC.mkDerivation {
    pname = "pragmasevka-nerd-font";
    version = "1.7.0";
    src = prev.fetchurl {
      url = "https://github.com/shytikov/pragmasevka/releases/download/v1.7.0/Pragmasevka_NF.zip";
      hash = "sha256-7qt1jv9WLRyu12EkRIjlZUW+Jegaa0DNhLMbAyo3YVw=";
    };
    nativeBuildInputs = [ prev.unzip ];
    unpackPhase = ''
      unzip $src -d pragmasevka
    '';
    installPhase = ''
      mkdir -p $out/share/fonts/truetype
      cp pragmasevka/*.ttf $out/share/fonts/truetype/
    '';
    meta.description = "Pragmasevka Nerd Font (PragmataPro doppelgänger from Iosevka)";
  };
}
