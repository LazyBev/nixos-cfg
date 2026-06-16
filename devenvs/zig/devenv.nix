{ pkgs, config, lib, ... }: {
  packages = with pkgs; [
    zig
    zls
  ];

  scripts.zig-build = {
    exec = "zig build";
    description = "Build project with Zig";
  };
  scripts.zig-test = {
    exec = "zig test src/main.zig";
    description = "Run Zig tests";
  };

  enterShell = ''
    echo "⚡ Zig devenv — ${pkgs.zig.version}"
  '';

  enterTest = ''
    echo "✓ zig available: $(zig version)"
  '';
}
