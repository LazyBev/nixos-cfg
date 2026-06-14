{ pkgs, ... }: {
  hjem.users.yari.packages = with pkgs; [
    alacritty btop dunst fuzzel
    grimblast hyprlock swaybg waypaper
    mpv pavucontrol playerctl
    qutebrowser librewolf rmpc
    thunar vesktop vscodium
    yazi zellij
    networkmanagerapplet
    bat fzf
  ];
}
