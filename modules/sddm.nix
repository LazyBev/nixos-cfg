{ pkgs, ... }: {
  services.greetd.enable = false;
  services.xserver.enable = true;
  services.libinput.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "catppuccin-mocha-mauve";
    settings.Input = {
      TapToClick = "true";
      NaturalScroll = "true";
      AccelSpeed = "0.2";
    };
  };
  services.displayManager.defaultSession = "niri-uwsm";
  environment.systemPackages = [ pkgs.catppuccin-sddm ];
  services.desktopManager.plasma6.enable = true;
}
