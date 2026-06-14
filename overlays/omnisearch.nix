final: prev: let
  beaker = prev.stdenv.mkDerivation {
    pname = "beaker";
    version = "git";
    src = builtins.fetchGit {
      url = "https://git.bwaaa.monster/beaker";
      rev = "3fab89ecf8f4c664477a82add660d28db87357b4";
    };
    makeFlags = [
      "INSTALL_PREFIX=$(out)/"
      "LDCONFIG=true"
    ];
  };
in {
  omnisearch = prev.stdenv.mkDerivation {
    pname = "omnisearch";
    version = "git";
    src = builtins.fetchGit {
      url = "https://git.bwaaa.monster/omnisearch";
      rev = "ddf39b56505a3a83bf888e245068160b4b5f24bd";
    };
    buildInputs = [
      prev.libxml2.dev
      prev.curl.dev
      prev.openssl
      beaker
    ];
    preBuild = ''
      makeFlagsArray+=(
        "PREFIX=$out"
        "CFLAGS=-Wall -Wextra -O2 -Isrc -I${prev.libxml2.dev}/include/libxml2"
        "LIBS=-lbeaker -lcurl -lxml2 -lpthread -lm -lssl -lcrypto"
      )
    '';
    installPhase = ''
      mkdir -p $out/bin $out/share/omnisearch
      install -Dm755 bin/omnisearch $out/bin/omnisearch
      cp -r templates static -t $out/share/omnisearch/
    '';
  };
}
