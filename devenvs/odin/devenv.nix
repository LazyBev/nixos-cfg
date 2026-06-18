{ pkgs, config, lib, ... }: {
  packages = with pkgs; [
    odin
    ols
  ];

  scripts.odin-build = {
    exec = "odin build .";
    description = "Build project with Odin";
  };
  scripts.odin-run = {
    exec = "odin run .";
    description = "Run project with Odin";
  };
  scripts.odin-test = {
    exec = "odin test .";
    description = "Run Odin tests";
  };

  enterShell = ''
    echo "◇ Odin devenv — ${pkgs.odin.version}"
  '';

  enterTest = ''
    echo "✓ odin available: $(odin version)"
  '';
}
