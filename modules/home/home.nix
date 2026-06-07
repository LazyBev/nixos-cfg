{ inputs, ... }: let
  vars = import ../../vars.nix;
in {
  flake.nixosModules.home = { config, lib, pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.${vars.username} = { pkgs, lib, ... }: {
        home.username = vars.username;
        home.homeDirectory = "/home/${vars.username}";
        home.stateVersion = "26.05";

        programs.home-manager.enable = true;

        programs.bat = {
          enable = true;
          config.theme = "ansi";
        };

        programs.fzf = {
          enable = true;
          colors = {
            "bg"      = "#282a36";
            "bg+"     = "#44475a";
            "fg"      = "#f8f8f2";
            "fg+"     = "#f8f8f2";
            "hl"      = "#bd93f9";
            "hl+"     = "#bd93f9";
            "info"    = "#8be9fd";
            "marker"  = "#ff79c6";
            "prompt"  = "#bd93f9";
            "spinner" = "#ff79c6";
            "pointer" = "#ff79c6";
            "header"  = "#6272a4";
            "border"  = "#44475a";
            "query"   = "#f8f8f2";
          };
        };

        gtk = {
          enable = true;
          theme = {
            name = "Dracula";
            package = pkgs.dracula-theme;
          };
          iconTheme = {
            name = "Dracula";
            package = pkgs.dracula-icon-theme;
          };
          font = {
            name = "JetBrainsMono Nerd Font";
            size = 10;
          };
          gtk2.force = true;
          gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
        };

        qt = {
          enable = true;
          platformTheme.name = "gtk";
          style = {
            name = "adwaita-dark";
            package = pkgs.adwaita-qt;
          };
        };

        dconf.settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = "Dracula";
            icon-theme = "Dracula";
            cursor-theme = "catppuccin-mocha-mauve-cursors";
            cursor-size = 24;
            font-name = "JetBrainsMono Nerd Font 10";
          };
        };

        home.activation.removeConflictingGtkFiles = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
          rm -f /home/${vars.username}/.config/gtk-3.0/settings.ini /home/${vars.username}/.config/gtk-4.0/settings.ini
        '';

        gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;


        programs.vesktop = {
          enable = true;
          vencord.settings =
            (builtins.fromJSON (builtins.readFile ../../configs/apps/vesktop/settings.json)).settings;
        };

        xdg.configFile."dunst/dunstrc".source                         = ../../configs/apps/dunst/dunstrc;
        xdg.configFile."fuzzel/fuzzel.ini".source                     = ../../configs/apps/fuzzel/fuzzel.ini;
        xdg.configFile."yazi/theme.toml".source                       = ../../configs/apps/yazi/theme.toml;
        xdg.configFile."yazi/yazi.toml".source                        = ../../configs/apps/yazi/yazi.toml;
        xdg.configFile."yazi/keymap.toml".source                      = ../../configs/apps/yazi/keymap.toml;
        xdg.configFile."yazi/flavors/dracula.yazi/flavor.toml".source = ../../configs/apps/yazi/flavors/dracula.yazi/flavor.toml;
        xdg.configFile."yazi/flavors/dracula.yazi/tmtheme.xml".source = ../../configs/apps/yazi/flavors/dracula.yazi/tmtheme.xml;
        xdg.configFile."qutebrowser/config.py".source                 = ../../configs/apps/qutebrowser/config.py;
        xdg.configFile."gtklock/style.css".source                     = ../../configs/apps/gtklock/style.css;
        xdg.configFile."xdg-desktop-portal/portals.conf".text         = ''[preferred] default=gtk'';
        

        home.file."Pictures" = {
          source = ../../configs/desktop/Pictures;
          recursive = true;
        };
      };
    };
  };
}
