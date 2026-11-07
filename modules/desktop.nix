{ lib, pkgs, ... }:
let
  cursor = {
    theme = "Bibata-Modern-Ice";
    size = "24";
  };
in
{
  programs.niri.enable = true;

  services = {
    seatd.enable = true;
    getty.enable = true;
    greetd = {
      enable = true;
      settings.default_session.command = lib.getExe pkgs.tuigreet;
    };
  };

  xdg.portal.portals = [ pkgs.xdg-desktop-portal-gtk ];

  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
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
    };
    packages = with pkgs; [
      monocraft
      pragmasevka-nerd-font
      nerd-fonts.fira-code
      nerd-fonts.martian-mono
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
      material-design-icons
      mpvScripts.modernz
    ];
  };

  environment.variables = lib.mkMerge [
    {
      EDITOR = "/run/current-system/sw/bin/hx";
      VISUAL = "hx";
      TERMINAL = "alacritty";
      BROWSER = "qutebrowser";
      CARGO_HOME = [ "/home/yari/.cargo" ];
      NIXOS_FLAKE = "/home/yari/finix-cfg";
      GTK_THEME = "Oxocarbon";
      EZA_COLORS = "di=37:fi=90";
      LD_LIBRARY_PATH = [ "/run/opengl-driver/lib" ];
      FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
        "--color='fg:#cdd6f4,bg:#1e1e2e,hl:#cba6f7'"
        "--color='fg+:#f5f5f5,bg+:#313244,hl+:#f5c2e7'"
        "--color='info:#a6e3a1,prompt:#94e2d5,pointer:#89b4fa'"
        "--color='marker:#fab387,spinner:#f9e2af,header:#f38ba8'"
      ];
    }
    (lib.mkForce {
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_IM_MODULE = "fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      XCURSOR_THEME = cursor.theme;
      XCURSOR_SIZE = cursor.size;
    })
  ];
}
