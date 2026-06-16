{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    # Nerd Fonts (icons + symbols)
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.noto
    nerd-fonts.ubuntu-mono

    # Comprehensive Unicode coverage
    noto-fonts
    noto-fonts-color-emoji
    twemoji-color-font
    joypixels
    beedii
    noto-fonts-cjk-sans
    unifont
    font-awesome
    dejavu_fonts
    cantarell-fonts
    liberation_ttf
    ubuntu-classic
    material-design-icons
    pragmasevka-nerd-font

    # Widely used quality fonts
    fira-sans
    source-code-pro
    source-sans-pro
    inter
    open-sans
    lato
    roboto
    roboto-mono
    merriweather
    cascadia-code
    overpass
    raleway
    montserrat
    nunito
    nunito-sans
    ibm-plex
    lora
  ];
  fonts.enableDefaultPackages = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Pragmasevka Nerd Font" ];
}
