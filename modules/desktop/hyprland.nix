{ pkgs, config, ... }: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = pkgs.hyprland;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    pkgs.hyprland
    pkgs.hypridle
    pkgs.hyprlock
  ];
}
