{ lib, ... }: let
  inherit (builtins) readDir attrNames filter;
  dir = ./.;
  files = filter (f: f != "default.nix" && lib.hasSuffix ".nix" f) (attrNames (readDir dir));
in {
  imports = map (f: dir + "/${f}") files;
}
