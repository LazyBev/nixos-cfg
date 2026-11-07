# odin with raylib on the linker path.
{
  writeShellScriptBin,
  odin,
  raylib,
}:
writeShellScriptBin "odin" ''
  export LIBRARY_PATH="${raylib}/lib''${LIBRARY_PATH:+:$LIBRARY_PATH}"
  exec ${odin}/bin/odin "$@"
''
