final: prev: {
  dracula-custom-theme = prev.stdenvNoCC.mkDerivation {
    pname = "dracula-custom-theme";
    version = "1.0.0";
    src = ../themes/dracula-custom;
    installPhase = ''
      mkdir -p $out/share/themes/Dracula
      cp -r * $out/share/themes/Dracula/
    '';
    meta.description = "Dracula GTK theme (local)";
  };
}
