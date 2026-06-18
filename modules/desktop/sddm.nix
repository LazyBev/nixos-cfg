{ pkgs, ... }: {
  services.greetd.enable = false;

  services.xserver.enable = true;
  services.libinput.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${pkgs.catppuccin-sddm}/share/sddm/themes/catppuccin-mocha-mauve";
    settings = {
      Input = {
        TapToClick = "true";
        NaturalScroll = "true";
        AccelSpeed = "0.2";
      };
    };
  };
}
