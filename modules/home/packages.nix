{pkgs, inputs, ...}: let
  ffa = pkgs.fetchFirefoxAddon;

  impala-nm = pkgs.callPackage ../../pkgs/impala-nm {};

  librewolf-wrapped = pkgs.wrapFirefox pkgs.librewolf-unwrapped {
    nixExtensions = [
      (ffa { name = "ublock-origin"; url = "https://addons.mozilla.org/firefox/downloads/file/4814095/ublock_origin-1.71.0.xpi"; sha256 = "47f788a1fc2c014830b30bb0ef9588615701b98c5265fb19b8cf4ba779849feb"; })
      (ffa { name = "darkreader"; url = "https://addons.mozilla.org/firefox/downloads/file/4837294/darkreader-4.9.127.xpi"; sha256 = "25f06b10b43270266af63c8d25e01ecf5e497bd2d5411243ee6d19b3869296ad"; })
      (ffa { name = "vimium"; url = "https://addons.mozilla.org/firefox/downloads/file/4717567/vimium_ff-2.4.2.xpi"; sha256 = "131e2a67580e7ae9125ab19781159e61409fac47b441fc2782aab76396ead196"; })
      (ffa { name = "return-youtube-dislike"; url = "https://addons.mozilla.org/firefox/downloads/file/4371820/return_youtube_dislikes-3.0.0.18.xpi"; sha256 = "2d33977ce93276537543161f8e05c3612f71556840ae1eb98239284b8f8ba19e"; })
      (ffa { name = "privacy-badger"; url = "https://addons.mozilla.org/firefox/downloads/file/4700632/privacy_badger17-2026.2.20.xpi"; sha256 = "eea49f1461de5eb00eb17b22b2864b55b54acb577b0360687460fe982633fbd6"; })
      (ffa { name = "tampermonkey"; url = "https://addons.mozilla.org/firefox/downloads/file/4797143/tampermonkey-5.5.0.xpi"; sha256 = "190031c78dbc5696114835601f2c8e6b855ad1e134df5df278f8fc158c065908"; })
      (ffa { name = "facebook-container"; url = "https://addons.mozilla.org/firefox/downloads/file/4451874/facebook_container-2.3.12.xpi"; sha256 = "3369bd865877860e6d7d38399d5902b300d3d5737acb2d1342ff5beb1d3780c1"; })
      (ffa { name = "sidebery"; url = "https://addons.mozilla.org/firefox/downloads/file/4766841/sidebery-5.5.2.xpi"; sha256 = "43e7dd4b8f684e637193d645fbcc94fb182583d24ac9a5b58effc4fb4d9faef2"; })
      (ffa { name = "tabliss"; url = "https://addons.mozilla.org/firefox/downloads/file/3940751/tabliss-2.6.0.xpi"; sha256 = "de766810f234b1c13ffdb7047ae6cbf06ed79c3d08b51a07e4766fadff089c0f"; })
    ];
  };

  librewolf-i2p = pkgs.writeShellScriptBin "librewolf-i2p" ''
    exec ${pkgs.librewolf}/bin/librewolf --profile /home/yari/.config/librewolf/librewolf/nhjvl52u.i2p --no-remote "$@"
  '';
in {
  hjem.users.yari.packages = with pkgs; [
    alacritty
    btop
    bitwarden-desktop
    bemenu
    dunst
    waypaper
    mpv
    pavucontrol
    playerctl
    qutebrowser
    quickshell
    librewolf-wrapped
    librewolf-i2p
    lua
    gajim
    signal-desktop
    rmpc
    thunar
    vesktop
    vscodium
    yazi
    zellij
    networkmanagerapplet
    bat
    fzf
    gcc
    gh
    ghc
    go

    just
    tree
    zoxide
    cargo
    catppuccin-cursors

    devenv
    eza
    gtklock
    imv

    ocaml
    odin
    ripgrep
    rustc
    swaybg
    unar
    unzip
    zip
    gnused
    gawk
    gnugrep
    which
    zathura
    zig

    opencode
    keepassxc
    proton-vpn
    proton-vpn-cli
    protonmail-desktop
    gpu-screen-recorder

    monero-cli
    monero-gui
    xmrig
    motrix
    qbittorrent
    tor
    tor-browser
    xwayland-satellite
    ucspi-tcp
    inotify-tools
    android-tools
    brightnessctl
    pastel
    rsync
    dysk
    astroterm
    caligula
    impala-nm
    inputs.ribbon.packages.${pkgs.stdenv.hostPlatform.system}.default
    usbutils
  ];
}

