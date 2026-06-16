{ config, pkgs, lib, ... }: let
  vars = config.vars;
in {
  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "adwaita-dark";
  };

  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings = with lib.gvariant; {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = vars.gtkTheme;
          icon-theme = vars.iconTheme;
          cursor-theme = vars.cursorTheme;
          cursor-size = mkInt32 vars.cursorSize;
          font-name = "Pragmasevka Nerd Font 10";
        };
      };
    }];
  };

  environment.systemPackages = with pkgs; [ adwaita-qt ];
}
