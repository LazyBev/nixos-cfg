{ pkgs, lib, ... }: {
  packages = with pkgs; [
    rustc
    cargo
    clippy
    rust-analyzer
    rustfmt
    cargo-watch
    cargo-edit
    cargo-audit
  ];

  env.RUST_BACKTRACE = "1";

  scripts.rust-docs = {
    exec = "rustup doc";
    description = "Open Rust documentation in browser";
  };

  enterShell = ''
    echo "🦀 Rust devenv — ${pkgs.rustc.version}"
  '';

  enterTest = ''
    echo "✓ rustc: $(rustc --version)"
    echo "✓ cargo: $(cargo --version)"
  '';
}
