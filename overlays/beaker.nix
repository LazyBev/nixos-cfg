final: prev: let
  beaker-src = builtins.fetchGit {
    url = "https://git.bwaaa.monster/beaker";
    rev = "3fab89ecf8f4c664477a82add660d28db87357b4";
  };
in {
  beaker = prev.stdenv.mkDerivation {
    pname = "beaker";
    version = "git";
    src = beaker-src;
    makeFlags = [
      "INSTALL_PREFIX=$(out)/"
      "LDCONFIG=true"
    ];
  };
}
