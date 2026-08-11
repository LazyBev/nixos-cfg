{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
    pragmasevka-nerd-font
    monocraft
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    font-awesome
    material-design-icons
    nerd-fonts.martian-mono
    papirus-icon-theme
    mpvScripts.modernz
  ];
  fonts.enableDefaultPackages = true;
  fonts.fontconfig.defaultFonts = {
    monospace = [
      "Monocraft"
      "Pragmasevka Nerd Font"
    ];
    sansSerif = [
      "Noto Sans"
      "Noto Sans CJK"
    ];
    serif = [
      "Noto Serif"
      "Noto Serif CJK"
    ];
  };
}
