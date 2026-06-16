{ pkgs, config, lib, ... }: {
  packages = with pkgs; [
    shellcheck
    bash-language-server
    bats
    shfmt
    jq
    yq
  ];

  env.BASH_STACK_DIR = "${builtins.fetchGit {
    url = "https://github.com/cgsdev0/bash-stack";
    rev = "bf2dc6991adbcb86b1f7b0aa98536a8ad1438c00";
  }}";

  scripts.bash-new = {
    exec = "cp -r $BASH_STACK_DIR/* . && echo 'bash-stack scaffolded into current directory'";
    description = "Scaffold a new bash-stack project";
  };
  scripts.bash-lint = {
    exec = "shellcheck *.sh";
    description = "Lint all shell scripts";
  };
  scripts.bash-format = {
    exec = "shfmt -w *.sh";
    description = "Format all shell scripts";
  };

  enterShell = ''
    echo "📜 Bash-stack devenv"
    echo "   - shellcheck ${pkgs.shellcheck.version}"
    echo "   - bash-language-server: available"
    echo "   - bash-stack source: $BASH_STACK_DIR"
    echo ""
    echo "Commands:"
    echo "  bash-new     Scaffold a new bash-stack project"
    echo "  bash-lint    Lint scripts with shellcheck"
    echo "  bash-format  Format scripts with shfmt"
  '';

  enterTest = ''
    echo "✓ shellcheck: $(shellcheck --version | head -1)"
    echo "✓ bash-language-server: $(bash-language-server --version 2>&1)"
  '';
}
