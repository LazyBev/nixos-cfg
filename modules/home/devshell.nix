{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    alejandra
    nil
    statix
    nix-output-monitor
    nix-init
    nurl
    nh
  ];
}
