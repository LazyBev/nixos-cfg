{ pkgs, ... }: {
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
    ];
    overrides = {
      global = {
        Environment = {
          GTK_THEME = "Dracula";
        };
      };
    };
  };
}
