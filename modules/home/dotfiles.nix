{ pkgs, ... }: {
  hjem.users.yari.files = {
    ".config/niri/config.kdl".text = builtins.readFile ../../configs/niri/config.kdl;

    ".config/alacritty/alacritty.toml".text = builtins.readFile ../../configs/alacritty/alacritty.toml;
    ".config/dunst/dunstrc".text = builtins.readFile ../../configs/dunst/dunstrc;
    ".config/fcitx5/config".text = builtins.readFile ../../configs/fcitx5/config;
    ".config/fcitx5/profile".text = builtins.readFile ../../configs/fcitx5/profile;
    ".config/fcitx5/conf/chttrans.conf".text = builtins.readFile ../../configs/fcitx5/conf/chttrans.conf;
    ".config/fcitx5/conf/keyboard.conf".text = builtins.readFile ../../configs/fcitx5/conf/keyboard.conf;
    ".config/fcitx5/conf/notifications.conf".text = builtins.readFile ../../configs/fcitx5/conf/notifications.conf;
    ".config/fcitx5/conf/punctuation.conf".text = builtins.readFile ../../configs/fcitx5/conf/punctuation.conf;
    ".config/fcitx5/conf/spell.conf".text = builtins.readFile ../../configs/fcitx5/conf/spell.conf;
    ".config/waybar/config.jsonc".text = builtins.readFile ../../configs/waybar/config.jsonc;
    ".config/waybar/style.css".text = builtins.readFile ../../configs/waybar/style.css;
    ".config/waybar/colors.css".text = builtins.readFile ../../configs/waybar/colors.css;
    ".config/waybar/wittr.sh" = {
      text = builtins.readFile ../../configs/waybar/wittr.sh;
      executable = true;
    };
    ".config/waybar/custom_modules/media/media-now-playing.sh" = {
      text = builtins.readFile ../../configs/waybar/custom_modules/media/media-now-playing.sh;
      executable = true;
    };
    ".config/waybar/custom_modules/media/media-time.sh" = {
      text = builtins.readFile ../../configs/waybar/custom_modules/media/media-time.sh;
      executable = true;
    };
    ".config/waybar/custom_modules/cava/config".text = builtins.readFile ../../configs/waybar/custom_modules/cava/config;
    ".config/waybar/custom_modules/cava/visualizer.sh" = {
      text = builtins.readFile ../../configs/waybar/custom_modules/cava/visualizer.sh;
      executable = true;
    };
    ".config/waybar/custom_modules/logo.sh" = {
      text = builtins.readFile ../../configs/waybar/custom_modules/logo.sh;
      executable = true;
    };
    ".config/fuzzel/fuzzel.ini".text = builtins.readFile ../../configs/fuzzel/fuzzel.ini;
    ".config/librewolf/librewolf/rlubfwj2.default/chrome/userChrome.css".text = builtins.readFile ../../configs/librewolf/userChrome.css;
    ".config/librewolf/sidebery-sidebar.css".text = builtins.readFile ../../configs/librewolf/sidebery-sidebar.css;
    ".config/librewolf/librewolf/rlubfwj2.default/user.js".text = builtins.readFile ../../configs/librewolf/user.js;
    ".config/qutebrowser/config.py".text = builtins.readFile ../../configs/qutebrowser/config.py;
    ".config/rmpc/config.ron".text = builtins.readFile ../../configs/rmpc/config.ron;
    ".config/vesktop/settings.json".text = builtins.readFile ../../configs/vesktop/settings.json;
    ".config/yazi/yazi.toml".text = builtins.readFile ../../configs/yazi/yazi.toml;
    ".config/yazi/keymap.toml".text = builtins.readFile ../../configs/yazi/keymap.toml;
    ".config/yazi/theme.toml".text = builtins.readFile ../../configs/yazi/theme.toml;
    ".config/zellij/config.kdl".text = builtins.readFile ../../configs/zellij/config.kdl;
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
    ".config/Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=Dracula
    '';
    ".config/dunst/icons".source = ../../configs/dunst/icons;
    ".config/yazi/flavors/dracula.yazi/flavor.toml".text = builtins.readFile ../../configs/yazi/flavors/dracula.yazi/flavor.toml;
    ".config/yazi/flavors/dracula.yazi/tmtheme.xml".text = builtins.readFile ../../configs/yazi/flavors/dracula.yazi/tmtheme.xml;

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
