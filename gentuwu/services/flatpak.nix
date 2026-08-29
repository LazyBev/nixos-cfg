{
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "com.stremio.Stremio"
      "org.vinegarhq.Sober"
      "com.spotify.Client"
      "com.usebottles.bottles"
    ];
    overrides.global.Environment = {
      GTK_THEME = "catppuccin-mocha-mauve";
      ICON_THEME = "Papirus-Dark";
    };
  };
}
