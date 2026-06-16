{ pkgs, config, lib, ... }: {
  packages = with pkgs; [
    ocaml
    ocamlPackages.ocaml-lsp
    ocamlPackages.ocamlformat
    dune_3
    ocamlPackages.utop
    ocamlPackages.findlib
    ocamlPackages.menhir
  ];

  scripts.ocaml-repl = {
    exec = "utop";
    description = "Start OCaml REPL";
  };
  scripts.ocaml-build = {
    exec = "dune build";
    description = "Build with Dune";
  };

  enterShell = ''
    echo "🐫 OCaml devenv — ocaml ${pkgs.ocaml.version}"
  '';

  enterTest = ''
    echo "✓ ocaml available: $(ocaml -version)"
  '';
}
