{
  pkgs,
  inputs,
  ...
}:
let
  ffa = pkgs.fetchFirefoxAddon;

  librewolf-wrapped = pkgs.wrapFirefox pkgs.librewolf-unwrapped {
    nixExtensions = [
      (ffa {
        name = "ublock-origin";
        url = "https://addons.mozilla.org/firefox/downloads/file/4814095/ublock_origin-1.71.0.xpi";
        sha256 = "47f788a1fc2c014830b30bb0ef9588615701b98c5265fb19b8cf4ba779849feb";
      })
      (ffa {
        name = "darkreader";
        url = "https://addons.mozilla.org/firefox/downloads/file/4837294/darkreader-4.9.127.xpi";
        sha256 = "25f06b10b43270266af63c8d25e01ecf5e497bd2d5411243ee6d19b3869296ad";
      })
      (ffa {
        name = "vimium";
        url = "https://addons.mozilla.org/firefox/downloads/file/4717567/vimium_ff-2.4.2.xpi";
        sha256 = "131e2a67580e7ae9125ab19781159e61409fac47b441fc2782aab76396ead196";
      })
      (ffa {
        name = "return-youtube-dislike";
        url = "https://addons.mozilla.org/firefox/downloads/file/4371820/return_youtube_dislikes-3.0.0.18.xpi";
        sha256 = "2d33977ce93276537543161f8e05c3612f71556840ae1eb98239284b8f8ba19e";
      })
      (ffa {
        name = "privacy-badger";
        url = "https://addons.mozilla.org/firefox/downloads/file/4700632/privacy_badger17-2026.2.20.xpi";
        sha256 = "eea49f1461de5eb00eb17b22b2864b55b54acb577b0360687460fe982633fbd6";
      })
      (ffa {
        name = "tampermonkey";
        url = "https://addons.mozilla.org/firefox/downloads/file/4797143/tampermonkey-5.5.0.xpi";
        sha256 = "190031c78dbc5696114835601f2c8e6b855ad1e134df5df278f8fc158c065908";
      })
      (ffa {
        name = "facebook-container";
        url = "https://addons.mozilla.org/firefox/downloads/file/4451874/facebook_container-2.3.12.xpi";
        sha256 = "3369bd865877860e6d7d38399d5902b300d3d5737acb2d1342ff5beb1d3780c1";
      })
      (ffa {
        name = "sidebery";
        url = "https://addons.mozilla.org/firefox/downloads/file/4766841/sidebery-5.5.2.xpi";
        sha256 = "43e7dd4b8f684e637193d645fbcc94fb182583d24ac9a5b58effc4fb4d9faef2";
      })
      (ffa {
        name = "tabliss";
        url = "https://addons.mozilla.org/firefox/downloads/file/3940751/tabliss-2.6.0.xpi";
        sha256 = "de766810f234b1c13ffdb7047ae6cbf06ed79c3d08b51a07e4766fadff089c0f";
      })
      (ffa {
        name = "btroblox";
        url = "https://addons.mozilla.org/firefox/downloads/file/4555645/btroblox-3.6.21.xpi";
        sha256 = "87572eb0db7cbfb8572cfecbd356f1c1a354cd7d6df6af8b29e1aa0bd1aa00e5";
      })
    ];
  };

  impala-nm = pkgs.stdenv.mkDerivation {
    pname = "impala-nm";
    version = "0.1.8";
    src = pkgs.fetchurl {
      url = "https://github.com/aashish-thapa/wlctl/releases/download/v0.1.8/wlctl-x86_64-unknown-linux-musl";
      sha256 = "0nbzzmxvrxl96qzqnh8d1x25683hk5h0wlazj210b872swnxsi7k";
    };
    dontUnpack = true;
    installPhase = "install -m755 -D $src $out/bin/impala-nm";
  };

  keyclack = pkgs.writeShellScriptBin "keyclack" ''
    exec ${pkgs.python3.withPackages (ps: [ ps.evdev ])}/bin/python3 ${./bin/keyclack.py} "$@"
  '';

  fetch = pkgs.stdenv.mkDerivation {
    pname = "fetch";
    version = "2.1.0";
    src = pkgs.fetchFromGitHub {
      owner = "areofyl";
      repo = "fetch";
      rev = "v2.1.0";
      hash = "sha256-9ixx7XJcY4ktcN/lUfjvFljvHIEO2ktOebeGgL0ulHg=";
    };
    makeFlags = [ "PREFIX=${placeholder "out"}" ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postInstall = ''
      wrapProgram $out/bin/fetch --prefix PATH : ${
        pkgs.lib.makeBinPath [
          pkgs.fastfetch
          pkgs.pciutils
        ]
      }
    '';
    meta.mainProgram = "fetch";
  };
in
{
  hjem.users.yari.packages = with pkgs; [
    (writeShellScriptBin "rust-doc" ''
      exec xdg-open "${rustc.doc}/share/doc/docs/html/index.html"
    '')
    (writeShellScriptBin "odin-doc" ''
      exec xdg-open "$HOME/.local/share/doc/odin/odin-lang.org/docs/index.html"
    '')

    # ── Browsers ──────────────────────────────────────
    librewolf-wrapped
    qutebrowser

    # ── Messaging / Social ────────────────────────────
    signal-desktop
    vesktop
    gajim
    thunderbird
    briar-desktop
    protonmail-desktop
    weechat
    catgirl

    # ── Media ─────────────────────────────────────────
    mpv
    freetube
    mpvScripts.modernz
    mpvScripts.thumbfast
    alsa-lib
    pavucontrol
    playerctl
    sox
    pipewire
    ffmpeg
    imv
    wf-recorder
    slurp
    protonup-qt
    rmpc
    zrythm
    carla

    # ── Terminal / TUI ────────────────────────────────
    alacritty
    networkmanagerapplet
    nemo
    motrix
    qbittorrent
    bat
    eza
    zoxide
    fzf
    ripgrep
    rlwrap
    zellij
    yazi
    btop
    ncdu
    tree
    unar
    unzip
    zip
    gnused
    gawk
    nawk
    gnugrep
    glib
    just

    # ── Development ───────────────────────────────────
    tinycc
    clang
    gcc
    ncurses
    go
    lua
    rustc
    rustfmt
    rustup
    cargo
    zig
    odin
    ols
    ocaml
    nasm
    fasm
    asm-lsp
    cmake
    gnumake
    bmake
    vscodium
    zathura
    devenv
    raylib
    help2man
    pkg-config
    opencode
    gh
    inputs.nirimod.packages.${pkgs.stdenv.hostPlatform.system}.default
    (python3.withPackages (ps: [
      ps.pip
      ps.psutil
      ps.textual
    ]))

    # ── Network / DNS ─────────────────────────────────
    curl
    rsync
    iw
    bind
    dnsutils
    ldns
    ucspi-tcp
    openssl
    proton-vpn
    proton-vpn-cli
    yt-dlp

    # ── Privacy / Security ────────────────────────────
    tor
    tor-browser
    arti
    torsocks
    proxychains
    hashcat
    clamav
    keepassxc
    libpcap

    # ── System / Diagnostics ──────────────────────────
    pciutils
    usbutils
    brightnessctl
    pastel
    dysk
    astroterm
    caligula
    libnotify
    killall
    fastfetch
    strace
    ltrace
    inotify-tools
    android-tools

    # ── Misc ──────────────────────────────────────────
    impala-nm
    fetch
    keyclack
    hyprpicker
    opentabletdriver
    ncurses5
    xwayland-satellite
    qt6Packages.qt6ct
    libsForQt5.qt5ct
    (pkgs.writeShellScriptBin "artix-games-launcher" ''
      export GDK_BACKEND=x11
      exec ${pkgs.artix-games-launcher}/bin/artix-games-launcher "$@"
    '')
    obsidian
    hyfetch
    macchina
    (writeShellScriptBin "flstudio" ''
      export WINEPREFIX="$HOME/.flstudio-wine"
      export WINEARCH=win64

      if [ ! -d "$WINEPREFIX" ]; then
        echo "Creating Wine prefix..."
        wineboot --init
        echo "Installing fonts and runtimes..."
        winetricks fontsmooth-rgb gdiplus corefonts vcrun2019
      fi

      FL_EXE=$(find "$WINEPREFIX/drive_c/Program Files/Image-Line/" -name "FL64.exe" -print -quit 2>/dev/null)
      if [ -z "$FL_EXE" ]; then
        echo "FL64.exe not found. Download FL Studio 26.1.3 from https://www.image-line.com/fl-studio/download/"
        echo "Then run: WINEPREFIX=\"$WINEPREFIX\" wine ~/Downloads/flstudio_win64_26.1.3.exe"
        exit 1
      fi
      exec wine "$FL_EXE" "$@"
    '')
  ];
}
