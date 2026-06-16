{ ... }: {
  perSystem = { pkgs, ... }: {
    devShells.default = pkgs.mkShell {
      packages = with pkgs; [
        alejandra
        nil
        statix
        nix-output-monitor
        nix-init
        nurl
        nh
      ];
    };
  };
}
