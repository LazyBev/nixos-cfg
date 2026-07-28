{ config, pkgs, lib, ... }: {
  stylix = {
    enable = true;
    autoEnable = true;
    image = /home/yari/Pictures/matikanefuku.png;
    imageScalingMode = "fill";
    base16Scheme = {
      base00 = "1e1e2e"; base01 = "181825"; base02 = "313244"; base03 = "45475a";
      base04 = "585b70"; base05 = "cdd6f4"; base06 = "f5f5f5"; base07 = "ffffff";
      base08 = "f38ba8"; base09 = "fab387"; base0A = "f9e2af"; base0B = "a6e3a1";
      base0C = "94e2d5"; base0D = "89b4fa"; base0E = "cba6f7"; base0F = "f5c2e7";
    };
    polarity = "dark";
    cursor = {
      package = pkgs.catppuccin-cursors.mochaMauve;
      name = "catppuccin-mocha-mauve";
      size = 24;
    };
    fonts = {
      serif = { package = pkgs.noto-fonts; name = "Noto Serif"; };
      sansSerif = { package = pkgs.noto-fonts; name = "Noto Sans"; };
      monospace = { package = pkgs.monocraft; name = "Monocraft"; };
      emoji = { package = pkgs.noto-fonts-color-emoji; name = "Noto Color Emoji"; };
      sizes = { applications = 12; desktop = 12; popups = 12; terminal = 14; };
    };
    opacity = { applications = 1.0; desktop = 1.0; popups = 1.0; terminal = 0.95; };
    targets.grub.enable = false;
    targets.plymouth.enable = false;
  };
}
