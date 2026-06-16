{ pkgs, ... }: let
  kvantum = pkgs.libsForQt5.qtstyleplugin-kvantum;
in {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = _: true;
  nixpkgs.config.joypixels.acceptLicense = true;
  services.flatpak = {
    enable = true;
    packages = [
      "org.vinegarhq.Sober"
      "com.stremio.Stremio"
    ];
    update.onActivation = true;
  };
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
    playerctl
    zscroll
    cava
    catppuccin-cursors
    awww
    dracula-theme
    dracula-icon-theme
    dracula-qt5-theme
    kvantum
  ];
}
