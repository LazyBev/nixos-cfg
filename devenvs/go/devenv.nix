{ pkgs, ... }: {
  packages = with pkgs; [
    go
    gotools
    delve
    golangci-lint
  ];

  env.GOPATH = "$(pwd)/.go";

  scripts.go-test = {
    exec = "go test ./...";
    description = "Run all Go tests";
  };

  enterShell = ''
    echo "🐹 Go devenv — go ${pkgs.go.version}"
  '';

  enterTest = ''
    echo "✓ go available: $(go version)"
  '';
}
