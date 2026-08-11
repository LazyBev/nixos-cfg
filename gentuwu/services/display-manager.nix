{ pkgs, lib, ... }: {
  services.greetd.enable = false;
  services.xserver.enable = true;
  services.libinput.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = lib.mkForce "catppuccin-mocha-mauve";
    settings.Input = {
      TapToClick = "true";
      NaturalScroll = "true";
      AccelSpeed = "0.2";
    };
  };
  environment.systemPackages = [ pkgs.catppuccin-sddm ];
  services.displayManager.defaultSession = "niri";
}
