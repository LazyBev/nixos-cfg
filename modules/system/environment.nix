{ config, ... }: let
  vars = config.vars;
in {
  environment.sessionVariables = {
    GTK_THEME = vars.gtkTheme;
    XCURSOR_THEME = vars.cursorTheme;
    XCURSOR_SIZE = "${toString vars.cursorSize}";
    QT_STYLE_OVERRIDE = "kvantum";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "alacritty";
    BROWSER = "qutebrowser";
    NIXOS_FLAKE = vars.flakeDir;
    FZF_DEFAULT_OPTS = "--color='fg:#f8f8f2,bg:#282a36,hl:#bd93f9' --color='fg+:#f8f8f2,bg+:#424450,hl+:#bd93f9' --color='info:#ffb86c,prompt:#50fa7b,pointer:#50fa7b' --color='marker:#f1fa8c,spinner:#f1fa8c,header:#6272a4'";
  };
  environment.variables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";
  };
}
