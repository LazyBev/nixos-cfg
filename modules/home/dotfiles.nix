{ pkgs, ... }: {
  hjem.users.yari.files = {
    ".config/niri/config.kdl".source = ../../configs/niri/config.kdl;
    ".config/ribbon/config.rib".source = ../../configs/ribbon/config.rib;


    ".config/alacritty/alacritty.toml".source = ../../configs/alacritty/alacritty.toml;
    ".config/dunst/dunstrc".source = ../../configs/dunst/dunstrc;
    ".config/fcitx5/config".source = ../../configs/fcitx5/config;
    ".config/fcitx5/profile".source = ../../configs/fcitx5/profile;
    ".config/fcitx5/conf/chttrans.conf".source = ../../configs/fcitx5/conf/chttrans.conf;
    ".config/fcitx5/conf/keyboard.conf".source = ../../configs/fcitx5/conf/keyboard.conf;
    ".config/fcitx5/conf/notifications.conf".source = ../../configs/fcitx5/conf/notifications.conf;
    ".config/fcitx5/conf/punctuation.conf".source = ../../configs/fcitx5/conf/punctuation.conf;
    ".config/fcitx5/conf/spell.conf".source = ../../configs/fcitx5/conf/spell.conf;
    ".config/librewolf/librewolf/rlubfwj2.default/chrome/userChrome.css".source = ../../configs/librewolf/userChrome.css;
    ".config/librewolf/sidebery-sidebar.css".source = ../../configs/librewolf/sidebery-sidebar.css;
    ".config/librewolf/librewolf/rlubfwj2.default/user.js".source = ../../configs/librewolf/user.js;
    ".config/qutebrowser/config.py".source = ../../configs/qutebrowser/config.py;
    ".config/qutebrowser/styles/youtube.css".source = ../../configs/qutebrowser/styles/youtube.css;
    ".config/rmpc/config.ron".source = ../../configs/rmpc/config.ron;
    ".config/rmpc/theme.ron".source = ../../configs/rmpc/theme.ron;
    ".config/vesktop/settings.json".source = ../../configs/vesktop/vencord-settings.json;
    ".config/yazi/yazi.toml".source = ../../configs/yazi/yazi.toml;
    ".config/yazi/keymap.toml".source = ../../configs/yazi/keymap.toml;
    ".config/yazi/theme.toml".source = ../../configs/yazi/theme.toml;
    ".config/zellij/config.kdl".source = ../../configs/zellij/config.kdl;
    ".torrc".source = ../../configs/tor/torrc;
    ".config/catgirl/config".source = ../../configs/catgirl/config;
    ".config/bat/config".text = "--theme=ansi";
    ".config/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Dracula
      gtk-icon-theme-name=Dracula
      gtk-cursor-theme-name=catppuccin-mocha-mauve-cursors
      gtk-cursor-theme-size=24
      gtk-application-prefer-dark-theme=1
    '';
    ".config/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-theme-name=Dracula
      gtk-icon-theme-name=Dracula
      gtk-cursor-theme-name=catppuccin-mocha-mauve-cursors
      gtk-cursor-theme-size=24
      gtk-application-prefer-dark-theme=1
    '';
    ".config/fetch/config".text = ''
      os
      host
      kernel
      uptime
      packages
      shell
      wm
      theme
      icons
      font
      cpu
      gpu
      memory
      swap
      disk
      ip
      battery
      colors
      label_color=magenta
      separator=─
      spin=xy
      speed=1.0
    '';
    ".config/Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=Dracula
    '';
    ".config/dunst/icons".source = ../../configs/dunst/icons;
    ".config/yazi/flavors/dracula.yazi/flavor.toml".source = ../../configs/yazi/flavors/dracula.yazi/flavor.toml;
    ".config/yazi/flavors/dracula.yazi/tmtheme.xml".source = ../../configs/yazi/flavors/dracula.yazi/tmtheme.xml;

    "Pictures/BURBER.png".source = ../../configs/Pictures/BURBER.png;
    "Pictures/YELLOW_BURBER.png".source = ../../configs/Pictures/YELLOW_BURBER.png;
    "Pictures/diinki.png".source = ../../configs/Pictures/diinki.png;
    "Pictures/higuruma.jpg".source = ../../configs/Pictures/higuruma.jpg;
    "Pictures/jodio.jpg".source = ../../configs/Pictures/jodio.jpg;
    "Pictures/manhattan.jpg".source = ../../configs/Pictures/manhattan.jpg;
    "Pictures/manhattan2.jpg".source = ../../configs/Pictures/manhattan2.jpg;
    "Pictures/matikanefuku.png".source = ../../configs/Pictures/matikanefuku.png;
    "Pictures/todo.png".source = ../../configs/Pictures/todo.png;
    "Pictures/yellow_burber_wall1.png".source = ../../configs/Pictures/yellow_burber_wall1.png;


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

    ".config/librewolf/librewolf/nhjvl52u.i2p/user.js".source = ../../configs/librewolf/i2p-user.js;

    ".config/fish/completions/topaz.fish".text = ''
      # topaz completions for fish

      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "-s" -d "Scan for WiFi networks"
      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "--scan" -d "Scan for WiFi networks"
      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "-I" -d "List wireless interfaces"
      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "--scan-interface" -d "List wireless interfaces"
      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "-p" -d "Port scan a host"
      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "--scan-ports" -d "Port scan a host"
      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "-c" -d "Crack WPA password"
      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "--crack" -d "Crack WPA password"
      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "-B" -d "Benchmark brute-force"
      complete -c topaz -n "not __fish_seen_subcommand_from -s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench" -f -a "--bench" -d "Benchmark brute-force"

      complete -c topaz -l verbose -s v -d "Show detailed progress"
      complete -c topaz -l help -s h -d "Show help"

      complete -c topaz -n "__fish_seen_subcommand_from -s --scan" -l max-channels -s n -r -d "Max channels to scan"
      complete -c topaz -n "__fish_seen_subcommand_from -s --scan" -l fresh -s f -d "Force fresh scan"

      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l wordlist -s w -r -d "Wordlist file"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l brute-force -s b -d "Brute-force"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l length -s L -r -d "Max password length"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l mask -s m -r -d "Mask pattern"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l deauth -s d -d "Send deauth"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l reconnect -s R -d "Create monitor VIF"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l nmcli -s N -d "Auto-connect via nmcli"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l single-threaded -s 1 -d "Single thread"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l no-hashcat -s X -d "Skip hashcat"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l channel -s C -r -d "Channel"
      complete -c topaz -n "__fish_seen_subcommand_from -c --crack" -l display-password-hash -s D -x -a "K M G S" -d "Force rate unit"

      complete -c topaz -n "__fish_seen_subcommand_from -p --scan-ports" -l threads -s t -r -d "Thread count"
      complete -c topaz -n "__fish_seen_subcommand_from -p --scan-ports" -l range -s r -r -d "Port range"
      complete -c topaz -n "__fish_seen_subcommand_from -p --scan-ports" -l udp -s u -d "UDP scan"

      complete -c topaz -n "__fish_seen_subcommand_from -B --bench" -l length -s L -r -d "Max password length"
      complete -c topaz -n "__fish_seen_subcommand_from -B --bench" -l output -s o -r -d "Log passwords to file"
      complete -c topaz -n "__fish_seen_subcommand_from -B --bench" -l threads -s t -r -d "Thread count"
      complete -c topaz -n "__fish_seen_subcommand_from -B --bench" -l single-threaded -s 1 -d "Single thread"
      complete -c topaz -n "__fish_seen_subcommand_from -B --bench" -l set-password -s P -r -d "Test password"
      complete -c topaz -n "__fish_seen_subcommand_from -B --bench" -l no-hashcat -s X -d "Skip hashcat"
      complete -c topaz -n "__fish_seen_subcommand_from -B --bench" -l display-password-hash -s D -x -a "K M G S" -d "Force rate unit"
    '';

    ".local/share/bash-completion/completions/topaz".text = ''
      # topaz completions for bash

      _topaz() {
          local cur prev words cword
          _init_completion || return

          if [[ $cword -eq 1 ]]; then
              COMPREPLY=($(compgen -W "-s --scan -I --scan-interface -p --scan-ports -c --crack -B --bench -v --verbose -h --help" -- "$cur"))
              return
          fi

          case "''${words[1]}" in
              -s|--scan)
                  COMPREPLY=($(compgen -W "-n --max-channels -f --fresh" -- "$cur"))
                  ;;
              -c|--crack)
                  COMPREPLY=($(compgen -W "-w --wordlist -b --brute-force -L --length -m --mask -d --deauth -R --reconnect -N --nmcli -1 --single-threaded -X --no-hashcat -C --channel -D --display-password-hash" -- "$cur"))
                  ;;
              -p|--scan-ports)
                  COMPREPLY=($(compgen -W "-t --threads -r --range -u --udp" -- "$cur"))
                  ;;
              -B|--bench)
                  COMPREPLY=($(compgen -W "-L --length -o --output -t --threads -1 --single-threaded -P --set-password -X --no-hashcat -D --display-password-hash" -- "$cur"))
                  ;;
          esac
      }
      complete -F _topaz topaz
    '';
  };
}
