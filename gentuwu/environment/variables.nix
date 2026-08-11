{ config, lib, ... }:
let
  vars = config.vars;
in
{
  environment.sessionVariables = {
    GTK_THEME = vars.gtkTheme;
    XCURSOR_THEME = vars.cursorTheme;
    XCURSOR_SIZE = "${toString vars.cursorSize}";
    EDITOR = "hx";
    VISUAL = "hx";
    TERMINAL = "alacritty";
    BROWSER = "qutebrowser";
    CARGO_HOME = [ "/home/yari/.cargo" ];
    NIXOS_FLAKE = vars.flakeDir;
    EZA_COLORS = "di=37:fi=90";
    FZF_DEFAULT_OPTS = "--color='fg:#cdd6f4,bg:#1e1e2e,hl:#cba6f7' --color='fg+:#f5f5f5,bg+:#313244,hl+:#f5c2e7' --color='info:#a6e3a1,prompt:#94e2d5,pointer:#89b4fa' --color='marker:#fab387,spinner:#f9e2af,header:#f38ba8'";
    LD_LIBRARY_PATH = "/run/opengl-driver/lib";
  };
  environment.variables = lib.mkForce {
    QT_IM_MODULE = "fcitx";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "fcitx";
    XCURSOR_THEME = vars.cursorTheme;
    XCURSOR_SIZE = "${toString vars.cursorSize}";
  };
}
