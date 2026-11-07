{ writeShellScriptBin, python3 }:
writeShellScriptBin "keyclack" ''
  exec ${python3.withPackages (ps: [ ps.evdev ])}/bin/python3 ${./keyclack.py} "$@"
''
