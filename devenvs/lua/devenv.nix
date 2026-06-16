{ pkgs, config, lib, ... }: {
  packages = with pkgs; [
    lua
    lua-language-server
    luarocks
    stylua
  ];

  scripts.lua-run = {
    exec = "lua src/main.lua";
    description = "Run main Lua script";
  };
  scripts.lua-format = {
    exec = "stylua .";
    description = "Format all Lua files";
  };

  enterShell = ''
    echo "🌙 Lua devenv — lua ${pkgs.lua.version}"
  '';

  enterTest = ''
    echo "✓ lua available: $(lua -v 2>&1)"
  '';
}
