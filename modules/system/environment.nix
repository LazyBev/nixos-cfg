{ config, pkgs, ... }: let
  vars = config.vars;
in {
  environment.sessionVariables = {
    GTK_THEME = vars.gtkTheme;
    XCURSOR_THEME = vars.cursorTheme;
    XCURSOR_SIZE = "${toString vars.cursorSize}";
    EDITOR = "hx";
    VISUAL = "hx";
    TERMINAL = "alacritty";
    BROWSER = "qutebrowser";
    NIXOS_FLAKE = vars.flakeDir;
    EZA_COLORS = "di=37:fi=90";
    FZF_DEFAULT_OPTS = "--color='fg:#d4d4d4,bg:#0a0a0a,hl:#aaaaaa' --color='fg+:#ffffff,bg+:#1e1e1e,hl+:#cccccc' --color='info:#888888,prompt:#999999,pointer:#999999' --color='marker:#bbbbbb,spinner:#bbbbbb,header:#555555'";
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };
  environment.variables = {
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "fcitx";
    XCURSOR_THEME = vars.cursorTheme;
    XCURSOR_SIZE = "${toString vars.cursorSize}";
  };
}
