{ pkgs, ... }: {
  packages = with pkgs; [
    python3
    ruff
    pyright
    uv
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.setuptools
  ];

  env.PIP_USER = "1";
  env.PYTHONDONTWRITEBYTECODE = "1";

  scripts.poetry-install = {
    exec = "poetry install";
    description = "Install dependencies with Poetry";
  };

  enterShell = ''
    echo "🐍 Python devenv — python ${pkgs.python3.version}"
  '';

  enterTest = ''
    echo "✓ python available: $(python --version)"
  '';
}
