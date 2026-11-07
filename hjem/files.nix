{ lib, ... }:
let
  tree =
    target: src:
    lib.listToAttrs (
      map (file: {
        name = "${target}/${lib.removePrefix "${toString src}/" (toString file)}";
        value.source = file;
      }) (lib.filesystem.listFilesRecursive src)
    );

  profile = ".config/librewolf/librewolf/rlubfwj2.default";
in
{
  files =
    tree ".config/niri" ../dotfiles/niri
    // tree ".config/zellij" ../dotfiles/zellij
    // tree ".config/qutebrowser" ../dotfiles/qutebrowser
    // tree ".config/qt6ct" ../dotfiles/qt6ct
    // tree ".config/Kvantum/Oxocarbon" ../dotfiles/Kvantum/Oxocarbon
    // tree ".config/fcitx5" ../dotfiles/fcitx5
    // tree ".config/catgirl" ../dotfiles/catgirl
    // tree "Pictures" ../media/Pictures
    // tree ".local/share/keyclack" ../media/keyclack
    // {
      ".config/niri/matikanefuku.png".source = ../media/Pictures/matikanefuku.png;

      # LibreWolf
      "${profile}/user.js".source = ../dotfiles/librewolf/user.js;
      "${profile}/chrome/userChrome.css".source = ../dotfiles/librewolf/userChrome.css;
      ".config/librewolf/sidebery-sidebar.css".source = ../dotfiles/librewolf/sidebery-sidebar.css;
      ".config/librewolf/librewolf/profiles.ini".text = ''
        [Profile0]
        Name=default
        IsRelative=1
        Path=rlubfwj2.default
        Default=1

        [General]
        StartWithLastProfile=1
        Version=2
      '';

      # Theme (Oxocarbon)
      ".config/Kvantum/kvantum.kvconfig".text = "[General]\ntheme=Oxocarbon\n";
      ".config/gtk-3.0/gtk.css".source = ../dotfiles/gtk/oxocarbon.css;
      ".config/gtk-4.0/gtk.css".source = ../dotfiles/gtk/oxocarbon.css;
      ".themes/Oxocarbon/index.theme".source = ../dotfiles/themes/Oxocarbon/index.theme;
      ".themes/Oxocarbon/gtk-3.0/gtk.css".source = ../dotfiles/gtk/oxocarbon.css;
      ".themes/Oxocarbon/gtk-4.0/gtk.css".source = ../dotfiles/gtk/oxocarbon.css;

      # Small tool configs
      ".config/bat/config".text = ''--theme="Catppuccin Mocha"'';
      ".config/asm-lsp/.asm-lsp.toml".text = ''
        [default_config]
        assembler = "fasm"
        instruction_set = "x86/x86-64"

        [default_config.opts]
        diagnostics = true
        default_diagnostics = true
      '';

      ".config/rmpc/config.ron".source = ../dotfiles/rmpc/config.ron;
      ".config/rmpc/theme.ron".source = ../dotfiles/rmpc/theme.ron;

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
        separator=
        spin=xy
        speed=1.0
      '';

      ".config/hyfetch.json".text = builtins.toJSON {
        preset = "transbian";
        mode = "rgb";
        light_dark = "dark";
        lightness = 0.65;
        color_align = {
          mode = "horizontal";
          custom_colors = [ ];
          fore_back = null;
        };
        backend = "macchina";
        args = null;
        distro = null;
        pride_month_shown = [ ];
        pride_month_disable = false;
      };
    };
}
