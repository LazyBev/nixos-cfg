{ writeShellScriptBin }:
writeShellScriptBin "odin-doc" ''
  exec xdg-open "$HOME/.local/share/doc/odin/odin-lang.org/docs/index.html"
''
