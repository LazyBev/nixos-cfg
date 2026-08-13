{
  config,
  pkgs,
  ...
}:
let
  vars = config.vars;
in
{
  hjem.clobberByDefault = true;
  hjem.users.yari.files = {
    ".config/niri/config.kdl".source = ../dotfiles/niri/config.kdl;
    ".config/niri/larp.png".source = ../dotfiles/niri/larp.png;
    ".local/share/keyclack".source = ../media/keyclack;
    ".config/niri/matikanefuku.png".source = ../media/Pictures/matikanefuku.png;
    ".config/noctalia/config.toml".source = ../dotfiles/noctalia/config.toml;
    ".config/alacritty/alacritty.toml".source = ../dotfiles/alacritty/alacritty.toml;
    ".config/zellij/config.kdl".source = ../dotfiles/zellij/config.kdl;
    ".config/bat/config".text = "--theme=\"Catppuccin Mocha\"";
    ".config/librewolf/librewolf/rlubfwj2.default/chrome/userChrome.css".source =
      ../dotfiles/librewolf/userChrome.css;
    ".config/librewolf/sidebery-sidebar.css".source = ../dotfiles/librewolf/sidebery-sidebar.css;
    ".config/librewolf/librewolf/rlubfwj2.default/user.js".source = ../dotfiles/librewolf/user.js;
    ".config/librewolf/librewolf/profiles.ini".text = ''
      [Profile0]
      Name=default
      IsRelative=1
      Path=rlubfwj2.default
      Default=1
      [Profile1]
      Name=i2p
      IsRelative=1
      Path=nhjvl52u.i2p
      [General]
      StartWithLastProfile=1
      Version=2
    '';
    ".config/librewolf/librewolf/nhjvl52u.i2p/user.js".source = ../dotfiles/librewolf/i2p-user.js;
    ".config/qutebrowser/config.py".source = ../dotfiles/qutebrowser/config.py;
    ".config/qutebrowser/styles/youtube.css".source = ../dotfiles/qutebrowser/styles/youtube.css;
    ".config/dunst/dunstrc".source = ../dotfiles/dunst/dunstrc;
    ".config/dunst/icons".source = ../dotfiles/dunst/icons;
    ".config/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=${vars.gtkTheme}
      gtk-icon-theme-name=${vars.iconTheme}
      gtk-cursor-theme-name=${vars.cursorTheme}
      gtk-cursor-theme-size=${toString vars.cursorSize}
      gtk-application-prefer-dark-theme=1
    '';
    ".config/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=${vars.gtkTheme}
      gtk-icon-theme-name=${vars.iconTheme}
      gtk-cursor-theme-name=${vars.cursorTheme}
      gtk-cursor-theme-size=${toString vars.cursorSize}
      gtk-application-prefer-dark-theme=1
    '';
    ".config/Kvantum/kvantum.kvconfig".text = "[General]\ntheme=${vars.gtkTheme}\n";
    ".config/qt6ct/qt6ct.conf".source = ../dotfiles/qt6ct/qt6ct.conf;
    ".config/qt6ct/colors/Catppuccin-Mocha.conf".source =
      ../dotfiles/qt6ct/colors/Catppuccin-Mocha.conf;
    ".config/fetch/config".text = ''
      os
      host
      kernel
      uptime
      packages
      shell
      wm
      theme
      icons
      font
      cpu
      gpu
      memory
      swap
      disk
      ip
      battery
      colors
      label_color=magenta
      separator=─
      spin=xy
      speed=1.0
    '';
    ".config/rmpc/config.ron".source = ../dotfiles/rmpc/config.ron;
    ".config/rmpc/theme.ron".source = ../dotfiles/rmpc/theme.ron;
    ".config/vesktop/settings.json".source = ../dotfiles/vesktop/vencord-settings.json;
    "Pictures/BURBER.png".source = ../media/Pictures/BURBER.png;
    "Pictures/YELLOW_BURBER.png".source = ../media/Pictures/YELLOW_BURBER.png;
    "Pictures/diinki.png".source = ../media/Pictures/diinki.png;
    "Pictures/higuruma.jpg".source = ../media/Pictures/higuruma.jpg;
    "Pictures/jodio.jpg".source = ../media/Pictures/jodio.jpg;
    "Pictures/manhattan.jpg".source = ../media/Pictures/manhattan.jpg;
    "Pictures/manhattan2.jpg".source = ../media/Pictures/manhattan2.jpg;
    "Pictures/matikanefuku.png".source = ../media/Pictures/matikanefuku.png;
    "Pictures/todo.png".source = ../media/Pictures/todo.png;
    "Pictures/yellow_burber_wall1.png".source = ../media/Pictures/yellow_burber_wall1.png;
    ".config/fcitx5/config".source = ../dotfiles/fcitx5/config;
    ".config/fcitx5/profile".source = ../dotfiles/fcitx5/profile;
    ".config/fcitx5/conf/chttrans.conf".source = ../dotfiles/fcitx5/conf/chttrans.conf;
    ".config/fcitx5/conf/keyboard.conf".source = ../dotfiles/fcitx5/conf/keyboard.conf;
    ".config/fcitx5/conf/notifications.conf".source = ../dotfiles/fcitx5/conf/notifications.conf;
    ".config/fcitx5/conf/punctuation.conf".source = ../dotfiles/fcitx5/conf/punctuation.conf;
    ".config/fcitx5/conf/spell.conf".source = ../dotfiles/fcitx5/conf/spell.conf;
    ".config/catgirl/config".source = ../dotfiles/catgirl/config;
    ".config/mpv/mpv.conf".text = ''
      osc=no keepaspect=yes vo=gpu-next gpu-context=wayland hwdec=vaapi profile=gpu-hq
    '';
    ".config/mpv/scripts/modernz.lua".source =
      "${pkgs.mpvScripts.modernz}/share/mpv/scripts/modernz.lua";
    ".config/mpv/scripts/thumbfast.lua".source =
      "${pkgs.mpvScripts.thumbfast}/share/mpv/scripts/thumbfast.lua";
    ".config/yazi/yazi.toml".source = ../dotfiles/yazi/yazi.toml;
    ".config/yazi/keymap.toml".source = ../dotfiles/yazi/keymap.toml;
    ".config/yazi/theme.toml".source = ../dotfiles/yazi/theme.toml;
    ".config/yazi/flavors/dracula.yazi/flavor.toml".source =
      ../dotfiles/yazi/flavors/dracula.yazi/flavor.toml;
    ".config/yazi/flavors/dracula.yazi/tmtheme.xml".source =
      ../dotfiles/yazi/flavors/dracula.yazi/tmtheme.xml;
    ".config/helix/config.toml".source = ../dotfiles/helix/config.toml;
    ".config/helix/languages.toml".source = ../dotfiles/helix/languages.toml;
    ".config/asm-lsp/.asm-lsp.toml".text =
      "[default_config]\nassembler = \"fasm\"\ninstruction_set = \"x86/x86-64\"\n[default_config.opts]\ndiagnostics = true\ndefault_diagnostics = true\n";
  };
}
