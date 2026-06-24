{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "impala-nm";
  version = "0.1.8";

  src = fetchurl {
    url = "https://github.com/aashish-thapa/wlctl/releases/download/v${version}/wlctl-x86_64-unknown-linux-musl";
    sha256 = "0nbzzmxvrxl96qzqnh8d1x25683hk5h0wlazj210b872swnxsi7k";
  };

  dontUnpack = true;

  installPhase = ''
    install -m755 -D $src $out/bin/impala-nm
  '';

  meta = with lib; {
    description = "TUI for managing wifi using NetworkManager";
    homepage = "https://github.com/aashish-thapa/wlctl";
    license = licenses.gpl3Only;
    maintainers = [];
    platforms = platforms.linux;
  };
}
