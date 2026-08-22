{ pkgs, ... }: {
  stylix = {
    enable = true;
    autoEnable = true;
    image = ../../dotfiles/niri/larp.png;
    imageScalingMode = "fill";
    polarity = "dark";
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    fonts = {
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      monospace = {
        package = pkgs.monocraft;
        name = "Monocraft";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 12;
        desktop = 12;
        popups = 12;
        terminal = 14;
      };
    };
    opacity = {
      applications = 1.0;
      desktop = 1.0;
      popups = 1.0;
      terminal = 0.95;
    };
    targets.grub.enable = false;
    targets.limine.enable = false;
    targets.plymouth.enable = false;
    targets.qt.enable = false;
    targets.gtk.enable = false;
  };
}
