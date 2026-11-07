# Out of tree upstream. Its Makefile leaves HAREFLAGS empty, so drive harec
# directly to keep the release/arch flags from hareHook's NIX_HAREFLAGS.
{
  stdenv,
  lib,
  fetchFromSourcehut,
  hareHook,
  hareThirdParty,
}:
stdenv.mkDerivation {
  pname = "hare-lsp";
  version = "0.2.1";

  src = fetchFromSourcehut {
    owner = "~whynothugo";
    repo = "hare-lsp";
    # Pinned by rev: fetchFromSourcehut strips the "v" off `tag`, which 404s.
    rev = "ca78f9f79eee38a7b1e112c4616f2333702905f4";
    hash = "sha256-uXH/T6JOA9cBFcLhCwY0mf4AA/VSrtVEiKfpAiVq2Ik=";
  };

  nativeBuildInputs = [
    hareHook
    hareThirdParty.hare-json
  ];

  buildPhase = ''
    runHook preBuild
    hare build $NIX_HAREFLAGS -o hare-lsp ./lsp/server/
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 hare-lsp -t $out/bin
    install -Dm644 LICENCE -t $out/share/licenses/hare-lsp
    runHook postInstall
  '';

  meta = {
    homepage = "https://git.sr.ht/~whynothugo/hare-lsp/";
    description = "Language server for the Hare programming language";
    license = lib.licenses.isc;
    platforms = hareHook.meta.platforms;
    mainProgram = "hare-lsp";
  };
}
