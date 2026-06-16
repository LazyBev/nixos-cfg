{ pkgs, config, lib, ... }: {
  packages = with pkgs; [
    gcc
    clang-tools
    cmake
    cmake-language-server
    gnumake
    gdb
    valgrind
    bear
  ];

  scripts.cc-build = {
    exec = "cmake -B build && cmake --build build";
    description = "Configure and build with CMake";
  };
  scripts.cc-debug = {
    exec = "cmake -B build -DCMAKE_BUILD_TYPE=Debug && cmake --build build";
    description = "Configure and build in debug mode";
  };

  enterShell = ''
    echo "🖥️  C/C++ devenv — gcc ${pkgs.gcc.version}"
  '';

  enterTest = ''
    echo "✓ gcc available: $(gcc --version | head -1)"
    echo "✓ cmake available: $(cmake --version | head -1)"
  '';
}
