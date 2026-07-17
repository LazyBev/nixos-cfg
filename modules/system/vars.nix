{ lib, ... }: {
  options.vars = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "yari";
      description = "Short name/alias";
    };
    username = lib.mkOption {
      type = lib.types.str;
      default = "LazyBev";
      description = "Primary username";
    };
    email = lib.mkOption {
      type = lib.types.str;
      default = "lazy25yari@proton.me";
      description = "Email address";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "gentuwu";
      description = "System hostname";
    };
    theme = lib.mkOption {
      type = lib.types.str;
      default = "Monochrome";
      description = "Desktop theme name";
    };
    gtkTheme = lib.mkOption {
      type = lib.types.str;
      default = "Adwaita-dark";
      description = "GTK theme name";
    };
    cursorTheme = lib.mkOption {
      type = lib.types.str;
      default = "Bibata-Modern-Classic";
      description = "Cursor theme name";
    };
    cursorSize = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size";
    };
    iconTheme = lib.mkOption {
      type = lib.types.str;
      default = "Adwaita";
      description = "Icon theme name";
    };
    flakeDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/yari/nixos-cfg";
      description = "Path to flake directory";
    };
    maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 4;
      description = "Maximum Nix build jobs";
    };
  };
}
