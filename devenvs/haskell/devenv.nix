{ pkgs, config, lib, ... }: {
  packages = with pkgs; [
    ghc
    cabal-install
    haskell-language-server
    fourmolu
    hlint
    haskellPackages.hoogle
  ];

  scripts.haskell-build = {
    exec = "cabal build";
    description = "Build with Cabal";
  };
  scripts.haskell-repl = {
    exec = "cabal repl";
    description = "Start Cabal REPL";
  };

  enterShell = ''
    echo "λ Haskell devenv — ghc ${pkgs.ghc.version}"
  '';

  enterTest = ''
    echo "✓ ghc available: $(ghc --version)"
    echo "✓ cabal available: $(cabal --version | head -1)"
  '';
}
