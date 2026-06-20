{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    pragmasevka-nerd-font
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    font-awesome
    material-design-icons
    dracula-theme
  ];
  fonts.enableDefaultPackages = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Pragmasevka Nerd Font" ];
}
