{
  config,
  lib,
  pkgs,
  ...
}:
let
  vars = config.vars;
in
{
  qt.enable = true;

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = with lib.gvariant; {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = vars.gtkTheme;
            icon-theme = vars.iconTheme;
            cursor-theme = vars.cursorTheme;
            cursor-size = mkInt32 vars.cursorSize;
            font-name = "Monocraft 10";
          };
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    alejandra
    nil
    statix
    nix-output-monitor
    nix-init
    nurl
    nh
    (pkgs.catppuccin-gtk.override {
      variant = "mocha";
      accents = [ "mauve" ];
    })
    (pkgs.catppuccin-kvantum.override {
      variant = "mocha";
      accent = "mauve";
    })
    pkgs.qt6Packages.qtstyleplugin-kvantum
    papirus-icon-theme
    grayjay
    wl-clipboard
    helix
    pkgit
    wl-mirror
  ];
}
