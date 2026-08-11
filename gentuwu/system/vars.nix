{ lib, ... }:
let
  h = import ../../lib/helpers.nix { inherit lib; };
in
{
  options.vars = {
    name = h.mkStrOpt "yari" "Short name/alias";
    username = h.mkStrOpt "LazyBev" "Primary username";
    email = h.mkStrOpt "lazy25yari@proton.me" "Email address";
    hostname = h.mkStrOpt "gentuwu" "System hostname";
    theme = h.mkStrOpt "Catppuccin-Mocha-Mauve" "Desktop theme name";
    gtkTheme = h.mkStrOpt "catppuccin-mocha-mauve" "GTK theme name";
    cursorTheme = h.mkStrOpt "Bibata-Modern-Ice" "Cursor theme name";
    cursorSize = h.mkIntOpt 24 "Cursor size";
    iconTheme = h.mkStrOpt "Papirus-Dark" "Icon theme name";
    flakeDir = h.mkStrOpt "/home/yari/nixos-cfg" "Path to flake directory";
    maxJobs = h.mkIntOpt 4 "Maximum Nix build jobs";
  };
}
