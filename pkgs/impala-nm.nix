{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "impala-nm";
  version = "0.1.8";

  src = fetchurl {
    url = "https://github.com/aashish-thapa/wlctl/releases/download/v0.1.8/wlctl-x86_64-unknown-linux-musl";
    sha256 = "0nbzzmxvrxl96qzqnh8d1x25683hk5h0wlazj210b872swnxsi7k";
  };

  dontUnpack = true;
  installPhase = "install -Dm755 $src $out/bin/impala-nm";
}
