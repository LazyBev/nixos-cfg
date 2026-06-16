{ lib, ... }: {
  options.vars = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "yari";
      description = "Primary username";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "gentuwu";
      description = "System hostname";
    };
    theme = lib.mkOption {
      type = lib.types.str;
      default = "Dracula";
      description = "Desktop theme name";
    };
    gtkTheme = lib.mkOption {
      type = lib.types.str;
      default = "Dracula";
      description = "GTK theme name";
    };
    cursorTheme = lib.mkOption {
      type = lib.types.str;
      default = "catppuccin-mocha-mauve-cursors";
      description = "Cursor theme name";
    };
    cursorSize = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size";
    };
    iconTheme = lib.mkOption {
      type = lib.types.str;
      default = "Dracula";
      description = "Icon theme name";
    };
    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/yari/nix";
      description = "Path to flake directory";
    };
    maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Maximum Nix build jobs";
    };
  };
}
