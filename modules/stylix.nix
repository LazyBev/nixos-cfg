{ config, pkgs, lib, ... }: {
  stylix = {
    enable = true;
    autoEnable = true;
    image = /home/yari/Pictures/matikanefuku.png;
    imageScalingMode = "fill";
    base16Scheme = {
      base00 = "0a0a0a"; base01 = "121212"; base02 = "1c1c1c"; base03 = "2a2a2a";
      base04 = "666666"; base05 = "e0e0e0"; base06 = "f0f0f0"; base07 = "ffffff";
      base08 = "999999"; base09 = "bbbbbb"; base0A = "cccccc"; base0B = "aaaaaa";
      base0C = "bbbbbb"; base0D = "dddddd"; base0E = "888888"; base0F = "777777";
    };
    polarity = "dark";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    fonts = {
      serif = { package = pkgs.noto-fonts; name = "Noto Serif"; };
      sansSerif = { package = pkgs.noto-fonts; name = "Noto Sans"; };
      monospace = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font"; };
      emoji = { package = pkgs.noto-fonts-color-emoji; name = "Noto Color Emoji"; };
      sizes = { applications = 12; desktop = 12; popups = 12; terminal = 14; };
    };
    opacity = { applications = 1.0; desktop = 1.0; popups = 1.0; terminal = 0.95; };
    targets.grub.enable = false;
  };
}
