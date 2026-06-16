{ pkgs, ... }: {
  services.greetd.enable = false;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${pkgs.catppuccin-sddm}/share/sddm/themes/catppuccin-mocha-mauve";
  };
}
