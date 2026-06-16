{ ... }: {
  programs.niri = {
    enable = true;
    withUWSM = true;
  };

  services.gnome.gnome-keyring.enable = false;
}
