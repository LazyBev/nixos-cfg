{ pkgs, ... }: {
  hjem.users.yari.files = {
    ".config/niri/config.kdl".source = ../../configs/niri/config.kdl;

    ".config/noctalia/config.toml".source = ../../configs/noctalia/config.toml;
    ".config/noctalia/nixos-logo.png".source = ../../configs/noctalia/nixos-logo.png;

    ".config/alacritty/alacritty.toml".source = ../../configs/alacritty/alacritty.toml;
    ".config/dunst/dunstrc".source = ../../configs/dunst/dunstrc;
    ".config/fcitx5/config".source = ../../configs/fcitx5/config;
    ".config/fcitx5/profile".source = ../../configs/fcitx5/profile;
    ".config/fcitx5/conf/chttrans.conf".source = ../../configs/fcitx5/conf/chttrans.conf;
    ".config/fcitx5/conf/keyboard.conf".source = ../../configs/fcitx5/conf/keyboard.conf;
    ".config/fcitx5/conf/notifications.conf".source = ../../configs/fcitx5/conf/notifications.conf;
    ".config/fcitx5/conf/punctuation.conf".source = ../../configs/fcitx5/conf/punctuation.conf;
    ".config/fcitx5/conf/spell.conf".source = ../../configs/fcitx5/conf/spell.conf;
    ".config/librewolf/librewolf/rlubfwj2.default/chrome/userChrome.css".source = ../../configs/librewolf/userChrome.css;
    ".config/librewolf/sidebery-sidebar.css".source = ../../configs/librewolf/sidebery-sidebar.css;
    ".config/librewolf/librewolf/rlubfwj2.default/user.js".source = ../../configs/librewolf/user.js;
    ".config/qutebrowser/config.py".source = ../../configs/qutebrowser/config.py;
    ".config/rmpc/config.ron".source = ../../configs/rmpc/config.ron;
    ".config/vesktop/settings.json".source = ../../configs/vesktop/settings.json;
    ".config/yazi/yazi.toml".source = ../../configs/yazi/yazi.toml;
    ".config/yazi/keymap.toml".source = ../../configs/yazi/keymap.toml;
    ".config/yazi/theme.toml".source = ../../configs/yazi/theme.toml;
    ".config/zellij/config.kdl".source = ../../configs/zellij/config.kdl;
    ".config/bat/config".text = "--theme=ansi";
    ".config/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Dracula
      gtk-icon-theme-name=Dracula
      gtk-cursor-theme-name=catppuccin-mocha-mauve-cursors
      gtk-cursor-theme-size=24
      gtk-application-prefer-dark-theme=1
    '';
    ".config/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Dracula
      gtk-icon-theme-name=Dracula
      gtk-cursor-theme-name=catppuccin-mocha-mauve-cursors
      gtk-cursor-theme-size=24
      gtk-application-prefer-dark-theme=1
    '';
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
    ".config/Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=Dracula
    '';
    ".config/dunst/icons".source = ../../configs/dunst/icons;
    ".config/yazi/flavors/dracula.yazi/flavor.toml".source = ../../configs/yazi/flavors/dracula.yazi/flavor.toml;
    ".config/yazi/flavors/dracula.yazi/tmtheme.xml".source = ../../configs/yazi/flavors/dracula.yazi/tmtheme.xml;

    "Pictures/BURBER.png".source = ../../configs/Pictures/BURBER.png;
    "Pictures/YELLOW_BURBER.png".source = ../../configs/Pictures/YELLOW_BURBER.png;
    "Pictures/diinki.png".source = ../../configs/Pictures/diinki.png;
    "Pictures/higuruma.jpg".source = ../../configs/Pictures/higuruma.jpg;
    "Pictures/jodio.jpg".source = ../../configs/Pictures/jodio.jpg;
    "Pictures/manhattan.jpg".source = ../../configs/Pictures/manhattan.jpg;
    "Pictures/manhattan2.jpg".source = ../../configs/Pictures/manhattan2.jpg;
    "Pictures/matikanefuku.png".source = ../../configs/Pictures/matikanefuku.png;
    "Pictures/todo.png".source = ../../configs/Pictures/todo.png;
    "Pictures/yellow_burber_wall1.png".source = ../../configs/Pictures/yellow_burber_wall1.png;
  };
}
