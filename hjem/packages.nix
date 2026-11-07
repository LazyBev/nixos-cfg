{ pkgs, inputs, ... }:
{
  packages = with pkgs; [
    # Browsers
    librewolf-wrapped
    qutebrowser
    tor-browser

    # Chat / mail
    signal-desktop
    gajim
    briar-desktop
    weechat
    catgirl
    thunderbird
    protonmail-desktop

    # Media
    freetube
    yt-dlp
    ffmpeg
    sox
    imv
    playerctl
    rmpc
    wf-recorder
    slurp
    wl-clipboard
    wl-mirror
    libresprite
    obsidian

    # Shell / files
    zellij
    bat
    eza
    zoxide
    fzf
    ripgrep
    rlwrap
    btop
    ncdu
    tree
    nnn
    nemo
    unar
    unzip
    zip
    just
    qbittorrent
    motrix

    # Dev
    gcc
    clang
    tinycc
    cmake
    gnumake
    bmake
    pkg-config
    help2man
    rustc
    cargo
    rustfmt
    go
    zig
    lua
    ocaml
    hare
    hare-lsp
    nasm
    fasm
    asm-lsp
    odin
    odin-raylib
    odin-doc
    ols
    (python3.withPackages (ps: [
      ps.pip
      ps.psutil
      ps.textual
    ]))
    vscodium
    zathura
    devenv
    # opencode
    gh
    pkgit
    inputs.nirimod.packages.${stdenv.hostPlatform.system}.default

    # Nix tooling
    nixfmt
    nil
    statix
    nix-init
    nurl
    nix-output-monitor
    nh

    # Network / security
    iw
    dnsutils
    ldns
    ucspi-tcp
    openssl
    libpcap
    proton-vpn
    torsocks
    proxychains
    hashcat
    keepassxc

    # System / diagnostics
    pciutils
    usbutils
    brightnessctl
    killall
    inotify-tools
    ltrace
    dysk
    libnotify
    android-tools
    fastfetch
    hyfetch
    macchina
    fetch
    hyperfine
    astroterm
    caligula
    pastel

    # Desktop / theming
    alsa-lib
    networkmanagerapplet
    impala-nm
    keyclack
    hyprpicker
    xwayland-satellite
    qt6Packages.qt6ct
    qt6Packages.qtstyleplugin-kvantum
    papirus-icon-theme
    (catppuccin-gtk.override {
      variant = "mocha";
      accents = [ "mauve" ];
    })
    (catppuccin-kvantum.override {
      variant = "mocha";
      accent = "mauve";
    })

    # Games / misc
    protonup-qt
    grayjay
    ncurses5
    nawk
    glib
  ];
}
