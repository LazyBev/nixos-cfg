{ pkgs, ... }: let
  ioccc-top = pkgs.stdenv.mkDerivation {
    pname = "ioccc-top";
    version = "2024";
    src = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/ioccc-src/winner/master/2024/endoh2/2024_endoh2.tar.bz2";
      hash = "sha256-V1/JvWbhNY1Y3EAa1DIg3zla2IGcgntjQ35xwB5pOmI=";
    };
    dontUnpack = true;
    nativeBuildInputs = [ pkgs.bzip2 ];
    buildPhase = ''
      tar xjf "$src" --strip-components=2
      cc -O3 -DW=120 -DH=24 -Ddt=.01 -De=.5 -Du=.5 -Drpm=750 -Dtilt=5 prog.c -o top
      cc -O3 -DW=120 -DH=24 -Ddt=.01 -De=.5 -Du=.5 -Drpm=4000 -Dtilt=5 prog.c -o tipple
    '';
    installPhase = ''
      mkdir -p $out/bin $out/share/ioccc-top
      cp top tipple $out/bin/
      cp *.txt $out/share/ioccc-top/
    '';
    meta = {
      description = "IOCCC 2024 winning entry: obfuscated spinning top simulator";
      longDescription = ''
        A rigid-body physics engine simulating spinning tops in the terminal.
        Pipe a shape file (e.g., top.txt, tippe-top2.txt, bottle.txt) into the binary.
        Binaries: top (750 RPM), tipple (4000 RPM, for tippe tops).
      '';
      homepage = "https://www.ioccc.org/2024/endoh2/index.html";
      license = pkgs.lib.licenses.cc-by-sa-40;
      maintainers = [ ];
      mainProgram = "top";
    };
  };
in {
  hjem.users.yari.packages = [ ioccc-top ];
}
