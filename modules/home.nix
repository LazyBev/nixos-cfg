{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  vars = config.vars;
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
    ];
  };

  librewolf-i2p = pkgs.writeShellScriptBin "librewolf-i2p" ''
    exec ${pkgs.librewolf}/bin/librewolf --profile /home/yari/.config/librewolf/librewolf/nhjvl52u.i2p --no-remote "$@"
  '';

  impala-nm = pkgs.stdenv.mkDerivation {
    pname = "impala-nm";
    version = "0.1.8";
    src = pkgs.fetchurl {
      url = "https://github.com/aashish-thapa/wlctl/releases/download/v0.1.8/wlctl-x86_64-unknown-linux-musl";
      sha256 = "0nbzzmxvrxl96qzqnh8d1x25683hk5h0wlazj210b872swnxsi7k";
    };
    dontUnpack = true;
    installPhase = ''
      install -m755 -D $src $out/bin/impala-nm
    '';
  };

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
      wrapProgram $out/bin/fetch \
        --prefix PATH : ${
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
  # theme (qt, dconf)
  qt.enable = true;
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = with lib.gvariant; {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = vars.gtkTheme;
            icon-theme = vars.iconTheme;
            cursor-theme = vars.cursorTheme;
            cursor-size = mkInt32 vars.cursorSize;
            font-name = "Monocraft 10";
          };
        };
      }
    ];
  };

  environment.systemPackages = with pkgs; [
    alejandra
    nil
    statix
    nix-output-monitor
    nix-init
    nurl
    nh
    (pkgs.catppuccin-gtk.override { variant = "mocha"; accents = [ "mauve" ]; })
    (pkgs.catppuccin-kvantum.override { variant = "mocha"; accent = "mauve"; })
    papirus-icon-theme
    grayjay
    wl-clipboard
    helix
    pkgit
    wl-mirror
    raylib
  ];

  # hjem user config
  hjem.users.yari = {
    environment.sessionVariables = {
      PKG_CONFIG_PATH = "/etc/profiles/per-user/yari/lib/pkgconfig";
      LIBRARY_PATH = "/etc/profiles/per-user/yari/lib";
      C_INCLUDE_PATH = "/etc/profiles/per-user/yari/include";
      CPLUS_INCLUDE_PATH = "/etc/profiles/per-user/yari/include";
    };

    packages = with pkgs; [
      librewolf-wrapped
      librewolf-i2p
      impala-nm
      fetch
      opentabletdriver
      tinycc
      clang
      gcc
      wget
      ncurses
      gcc
      ghc
      go
      lua
      rustc
      rustfmt
      rustup
      cargo
      zig
      odin
      ocaml
      nasm
      fasm
      asm-lsp
      cmake
      gnumake
      flex
      bison
      byacc
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
      qutebrowser
      signal-desktop
      vesktop
      gajim
      thunderbird
      briar-desktop
      protonmail-desktop
      weechat
      catgirl
      ii
      mpv
      mpvScripts.modernz
      mpvScripts.thumbfast
      pavucontrol
      playerctl
      sox
      ffmpeg
      imv
      gpu-screen-recorder
      wf-recorder
      slurp
      osu-lazer-bin
      waypaper
      swaybg
      mpvpaper
      rmpc
      alacritty
      bemenu
      dunst
      hypridle
      hyprlock
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
      gnugrep
      which
      pciutils
      usbutils
      brightnessctl
      wget
      curl
      rsync
      pastel
      dysk
      astroterm
      caligula
      libnotify
      killall
      htop
      fastfetch
      strace
      ltrace
      inotify-tools
      iw
      bind
      dnsutils
      ucspi-tcp
      openssl
      proton-vpn
      proton-vpn-cli
      yt-dlp
      ncurses
      ncurses5
      xwayland-satellite
      catppuccin-cursors
      just
      tor
      tor-browser
      arti
      torsocks
      proxychains
      hashcat
      clamav
      keepassxc
      monero-cli
      monero-gui
      xmrig
      android-tools
      libpcap
      bitwarden-desktop
    ];

    files = {
      ".config/niri/config.kdl".source = ../dotfiles/niri/config.kdl;
      ".config/niri/larp.png".source = ../dotfiles/niri/larp.png;
      ".config/niri/matikanefuku.png".source = ../media/Pictures/matikanefuku.png;
      ".config/noctalia/config.toml".source = ../dotfiles/noctalia/config.toml;
      ".config/hypr/hyprlock.conf".source = ../dotfiles/hypr/hyprlock.conf;
      ".config/hypr/hypridle.conf".source = ../dotfiles/hypr/hypridle.conf;
      ".config/alacritty/alacritty.toml".source = ../dotfiles/alacritty/alacritty.toml;
      ".config/zellij/config.kdl".source = ../dotfiles/zellij/config.kdl;
      ".config/bat/config".text = "--theme=\"Catppuccin Mocha\"";
      ".config/librewolf/librewolf/rlubfwj2.default/chrome/userChrome.css".source =
        ../dotfiles/librewolf/userChrome.css;
      ".config/librewolf/sidebery-sidebar.css".source = ../dotfiles/librewolf/sidebery-sidebar.css;
      ".config/librewolf/librewolf/rlubfwj2.default/user.js".source = ../dotfiles/librewolf/user.js;
      ".config/librewolf/librewolf/profiles.ini".text = ''
        [Profile0]
        Name=default
        IsRelative=1
        Path=rlubfwj2.default
        Default=1
        [Profile1]
        Name=i2p
        IsRelative=1
        Path=nhjvl52u.i2p
        [General]
        StartWithLastProfile=1
        Version=2
      '';
      ".config/librewolf/librewolf/nhjvl52u.i2p/user.js".source = ../dotfiles/librewolf/i2p-user.js;
      ".config/qutebrowser/config.py".source = ../dotfiles/qutebrowser/config.py;
      ".config/qutebrowser/styles/youtube.css".source = ../dotfiles/qutebrowser/styles/youtube.css;
      ".config/dunst/dunstrc".source = ../dotfiles/dunst/dunstrc;
      ".config/dunst/icons".source = ../dotfiles/dunst/icons;
      ".config/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=${vars.gtkTheme}
        gtk-icon-theme-name=${vars.iconTheme}
        gtk-cursor-theme-name=${vars.cursorTheme}
        gtk-cursor-theme-size=${toString vars.cursorSize}
        gtk-application-prefer-dark-theme=1
      '';
      ".config/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-theme-name=${vars.gtkTheme}
        gtk-icon-theme-name=${vars.iconTheme}
        gtk-cursor-theme-name=${vars.cursorTheme}
        gtk-cursor-theme-size=${toString vars.cursorSize}
        gtk-application-prefer-dark-theme=1
      '';
      ".config/Kvantum/kvantum.kvconfig".text = "[General]\ntheme=${vars.gtkTheme}\n";
      ".config/fetch/config".text = ''
        os host kernel uptime packages shell wm theme icons font cpu
        gpu memory swap disk ip battery colors
        label_color=magenta separator=─ spin=xy speed=1.0
      '';
      ".config/rmpc/config.ron".source = ../dotfiles/rmpc/config.ron;
      ".config/rmpc/theme.ron".source = ../dotfiles/rmpc/theme.ron;
      ".config/vesktop/settings.json".source = ../dotfiles/vesktop/vencord-settings.json;
      "Pictures/BURBER.png".source = ../media/Pictures/BURBER.png;
      "Pictures/YELLOW_BURBER.png".source = ../media/Pictures/YELLOW_BURBER.png;
      "Pictures/diinki.png".source = ../media/Pictures/diinki.png;
      "Pictures/higuruma.jpg".source = ../media/Pictures/higuruma.jpg;
      "Pictures/jodio.jpg".source = ../media/Pictures/jodio.jpg;
      "Pictures/manhattan.jpg".source = ../media/Pictures/manhattan.jpg;
      "Pictures/manhattan2.jpg".source = ../media/Pictures/manhattan2.jpg;
      "Pictures/matikanefuku.png".source = ../media/Pictures/matikanefuku.png;
      "Pictures/todo.png".source = ../media/Pictures/todo.png;
      "Pictures/yellow_burber_wall1.png".source = ../media/Pictures/yellow_burber_wall1.png;
      ".config/fcitx5/config".source = ../dotfiles/fcitx5/config;
      ".config/fcitx5/profile".source = ../dotfiles/fcitx5/profile;
      ".config/fcitx5/conf/chttrans.conf".source = ../dotfiles/fcitx5/conf/chttrans.conf;
      ".config/fcitx5/conf/keyboard.conf".source = ../dotfiles/fcitx5/conf/keyboard.conf;
      ".config/fcitx5/conf/notifications.conf".source = ../dotfiles/fcitx5/conf/notifications.conf;
      ".config/fcitx5/conf/punctuation.conf".source = ../dotfiles/fcitx5/conf/punctuation.conf;
      ".config/fcitx5/conf/spell.conf".source = ../dotfiles/fcitx5/conf/spell.conf;
      ".config/catgirl/config".source = ../dotfiles/catgirl/config;
      ".config/mpv/mpv.conf".text = ''
        osc=no
        keepaspect=yes
        vo=gpu-next
        gpu-context=wayland
        hwdec=vaapi
        profile=gpu-hq
      '';
      ".config/mpv/scripts/modernz.lua".source =
        "${pkgs.mpvScripts.modernz}/share/mpv/scripts/modernz.lua";
      ".config/mpv/scripts/thumbfast.lua".source =
        "${pkgs.mpvScripts.thumbfast}/share/mpv/scripts/thumbfast.lua";
      ".config/yazi/yazi.toml".source = ../dotfiles/yazi/yazi.toml;
      ".config/yazi/keymap.toml".source = ../dotfiles/yazi/keymap.toml;
      ".config/yazi/theme.toml".source = ../dotfiles/yazi/theme.toml;
      ".config/yazi/flavors/dracula.yazi/flavor.toml".source =
        ../dotfiles/yazi/flavors/dracula.yazi/flavor.toml;
      ".config/yazi/flavors/dracula.yazi/tmtheme.xml".source =
        ../dotfiles/yazi/flavors/dracula.yazi/tmtheme.xml;
      ".config/helix/config.toml".source = ../dotfiles/helix/config.toml;
      ".config/helix/languages.toml".source = ../dotfiles/helix/languages.toml;
      ".config/asm-lsp/.asm-lsp.toml".text =
        "[default_config]\nassembler = \"fasm\"\ninstruction_set = \"x86/x86-64\"\n[default_config.opts]\ndiagnostics = true\ndefault_diagnostics = true\n";

    };
  };
}
