{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    vim
    killall
    libnotify
    brightnessctl
    jq
    unzip
    ripgrep
    fd
    eza
    bat
    fzf
    zoxide
    xdg-utils
    wl-clipboard
    nh
    nix-output-monitor
    dracula-custom-theme
    dracula-icon-theme
    dracula-qt5-theme
  ];
}
