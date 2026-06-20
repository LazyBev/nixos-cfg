{ lib, ... }: let
  inherit (builtins) readDir attrNames filter;

  collectNixFiles = dir:
    let
      entries = readDir dir;
      names = attrNames entries;
      isFile = n: entries.${n} == "regular";
      isDir = n: entries.${n} == "directory";
      nixFiles = filter (n: isFile n && lib.hasSuffix ".nix" n && n != "default.nix") names;
      directories = filter isDir names;
    in
      (map (n: dir + "/${n}") nixFiles)
      ++ lib.flatten (map (d: collectNixFiles (dir + "/${d}")) directories);
in {
  imports = collectNixFiles ./.;


  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
    permittedInsecurePackages = [
      "electron-39.8.10"
      "librewolf-151.0.2-1"
      "librewolf-unwrapped-151.0.2-1"
    ];
    joypixels.acceptLicense = true;
  };
}
