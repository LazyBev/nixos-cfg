{ config, pkgs, lib, ... }: {
  programs.niri = {
    enable = true;
    withUWSM = true;
  };
  services.gnome.gnome-keyring.enable = false;
  programs.hyprlock.enable = true;
  environment.systemPackages = [ pkgs.hypridle ];
}
