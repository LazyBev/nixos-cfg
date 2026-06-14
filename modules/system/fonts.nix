{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hack
    nerd-fonts.symbols-only
    nerd-fonts.iosevka
    dejavu_fonts
    pragmasevka-nerd-font
  ];
  fonts.enableDefaultPackages = true;
  fonts.fontconfig.defaultFonts.monospace = [ "Pragmasevka Nerd Font" ];
}
