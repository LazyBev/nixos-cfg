{ pkgs, config, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -gx LIBVIRT_DEFAULT_URI qemu:///system
      set -gx DOAS_PERSIST_TIMEOUT 0
      set -g fish_greeting
set -gx EZA_COLORS "di=96:fi=37:ex=92:ln=95:or=91:mi=91:su=93:sf=93:wu=93:sg=93:pi=93:so=93:bd=94:cd=94"

      function doas --wraps doas
        if test "$argv" = "!!"
            command doas (history -n 1)
        else
            command doas $argv
        end
      end
      zoxide init fish | source

      function gitwho
        git config --global user.name "$argv[1]"
        git config --global user.email "$argv[2]"
      end

      function prevd
        if set -q __last_dir
          cd "$__last_dir"
        else
          echo "No previous directory"
        end
      end

      function cd
        set -gx __last_dir "$PWD"
        builtin cd $argv
      end

      function gp
        git add .
        git commit -m "$argv"
        git push
      end

      function sysupd
        if test (count $argv) -lt 2
          echo "Usage: sysupd <config-dir> <hostname>"
          echo "Example: sysupd nixos-cfg gentuwu"
          return 1
        end
        pushd ~/$argv[1]
        nix flake update
        nh os switch ".#$argv[2]"
        popd
      end

      function update
        if test (count $argv) -lt 2
          echo "Usage: update <config-dir> <hostname>"
          echo "Example: update nixos-cfg gentuwu"
          return 1
        end
        nh os switch $HOME/$argv[1]#$argv[2]
      end

      function clrcache
        set dirs \
          ~/.cache \
          ~/.thumbnails \
          ~/.local/share/Trash \
          /tmp

        for d in $dirs
          if test -d "$d"
            rm -rf "$d/"* "$d/".*
          end
        end

        doas nix-collect-garbage -d
        doas nix-collect-garbage --delete-old
        nix store optimise
      end

      function irc
        weechat $argv
      end

      function catgirl
        command catgirl config $argv
      end

      function starttor --description 'Route all traffic through Tor'
        sudo systemctl stop tor 2>/dev/null; or true
        sudo pkill -f "tor -f /home/yari/.torrc" 2>/dev/null; or true
        sleep 1
        sudo tor -f /home/yari/.torrc & disown
        sleep 2
        set -l tor_uid (sudo id -u tor)

        # --- NAT: redirect TCP to TransPort ---
        sudo iptables -t nat -N TOR_PROXY 2>/dev/null; or sudo iptables -t nat -F TOR_PROXY
        sudo iptables -t nat -A TOR_PROXY -m owner --uid-owner $tor_uid -j RETURN
        sudo iptables -t nat -A TOR_PROXY -o lo -j RETURN
        sudo iptables -t nat -A TOR_PROXY -p tcp --dport 9040 -j RETURN
        sudo iptables -t nat -A TOR_PROXY -p tcp --dport 9050 -j RETURN
        sudo iptables -t nat -A TOR_PROXY -p tcp --dport 9051 -j RETURN
        sudo iptables -t nat -A TOR_PROXY -p tcp -j REDIRECT --to-ports 9040
        sudo iptables -t nat -A OUTPUT -j TOR_PROXY

        # --- NAT: redirect DNS to DNSPort ---
        sudo iptables -t nat -N TOR_DNS 2>/dev/null; or sudo iptables -t nat -F TOR_DNS
        sudo iptables -t nat -A TOR_DNS -m owner --uid-owner $tor_uid -j RETURN
        sudo iptables -t nat -A TOR_DNS -o lo -j RETURN
        sudo iptables -t nat -A TOR_DNS -p udp --dport 5353 -j RETURN
        sudo iptables -t nat -A TOR_DNS -p udp --dport 53 -j REDIRECT --to-ports 5353
        sudo iptables -t nat -A OUTPUT -j TOR_DNS

        # --- Filter: killswitch — only Tor traffic leaves ---
        sudo iptables -N TOR_OUT 2>/dev/null; or sudo iptables -F TOR_OUT
        sudo iptables -A TOR_OUT -m owner --uid-owner $tor_uid -j ACCEPT
        sudo iptables -A TOR_OUT -o lo -j ACCEPT
        sudo iptables -A TOR_OUT -p tcp --dport 9040 -j ACCEPT
        sudo iptables -A TOR_OUT -p tcp --dport 9050 -j ACCEPT
        sudo iptables -A TOR_OUT -p tcp --dport 9051 -j ACCEPT
        sudo iptables -A TOR_OUT -p udp --dport 5353 -j ACCEPT
        sudo iptables -A TOR_OUT -p udp --dport 123 -j ACCEPT
        sudo iptables -A TOR_OUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        sudo iptables -A TOR_OUT -j DROP
        sudo iptables -A OUTPUT -j TOR_OUT

        # --- IPv6: drop everything to prevent leaks ---
        sudo ip6tables -P OUTPUT DROP 2>/dev/null

        set -gx ALL_PROXY socks5://127.0.0.1:9050
        echo "traffic is now routed through Tor (~/.torrc)"
      end

      function clearnet --description 'Restore direct internet access'
        sudo iptables -F
        sudo iptables -t nat -F
        sudo iptables -X
        sudo ip6tables -P OUTPUT ACCEPT 2>/dev/null; or true
        sudo resolvectl dnssec wlan0 no
        sudo pkill -f "tor -f /home/yari/.torrc" 2>/dev/null; or true
        set -e ALL_PROXY
        echo "direct internet restored"
      end

      function flushfw --description 'Flush iptables and disable DNSSEC'
        doas resolvectl dnssec wlan0 no
        doas iptables -F
        doas iptables -t nat -F
        doas iptables -X
        echo "connection reset"
      end

      function iftor --description 'Check if traffic is routed through Tor'
        if doas iptables -C OUTPUT -j TOR_OUT 2>/dev/null
          echo "traffic is routed through Tor"
        else
          echo "traffic is direct"
        end
        doas systemctl is-active tor >/dev/null; and echo "tor daemon: active"; or echo "tor daemon: inactive"
      end

      function ifclear --description 'Check if traffic is direct (clearnet)'
        if doas iptables -C OUTPUT -j TOR_OUT 2>/dev/null
          echo "clearnet: no (traffic is routed through Tor)"
        else
          echo "clearnet: yes (traffic is direct)"
        end
      end

      function dev
        if test (count $argv) -lt 2
          echo "Usage: dev <config-dir> <language>"
          echo "Example: dev nixos-cfg rust"
          return 1
        end
        set dir ~/$argv[1]/devenvs/$argv[2]
        if not test -d "$dir"
          echo "Unknown devenv: $argv[2] in ~/$argv[1]/devenvs/"
          return 1
        end
        cd "$dir"
        devenv shell
      end

      function record --description 'Record screen with audio using wf-recorder'
        set output_dir ~/Videos
        set timestamp (date +%Y-%m-%d_%H-%M-%S)
        set filename "$output_dir/recording_$timestamp.mp4"
        set output_name eDP-1
        set geometry ""
        set no_audio 0

        argparse s/select A/area= o/output= f/file= a/no-audio h/help -- $argv
        or return

        if set -q _flag_help
            echo "Usage: record [OPTIONS]"
            echo ""
            echo "Record screen with audio using wf-recorder."
            echo ""
            echo "Options:"
            echo "  -o, --output <NAME>  Output to record (default: eDP-1)"
            echo "  -s, --select         Select a region to record (uses slurp)"
            echo "  -A, --area <GEO>     Specify geometry (e.g. '1920x1080+0+0')"
            echo "  -f, --file <FILE>    Output filename (default: ~/Videos/recording_<timestamp>.mp4)"
            echo "  -a, --no-audio       Record without audio"
            echo "  -h, --help           Show this help"
            return 0
        end

        if set -q _flag_file
            set filename $_flag_file
        end

        if set -q _flag_output
            set output_name $_flag_output
        end

        if set -q _flag_area
            set geometry $_flag_area
        end

        if set -q _flag_select
            if not command -q slurp
                notify-send -u critical "record: slurp not found" "Install slurp to use region selection"
                return 1
            end
            set geometry (slurp)
        end

        if set -q _flag_no_audio
            set no_audio 1
        end

        mkdir -p $output_dir

        notify-send -t 2000 "Recording starting" "Saving to $filename"

        if test $no_audio -eq 1
            if test -n "$geometry"
                wf-recorder -o $output_name -g "$geometry" -f "$filename"
            else
                wf-recorder -o $output_name -f "$filename"
            end
        else
            if test -n "$geometry"
                wf-recorder --audio -o $output_name -g "$geometry" -f "$filename"
            else
                wf-recorder --audio -o $output_name -f "$filename"
            end
        end

        if test $status -eq 0
            notify-send -t 3000 "Recording saved" "$filename"
        else
            notify-send -u critical "Recording failed" "wf-recorder exited with status $status"
        end
      end
    '';
    shellAliases = {
      cat = "bat -p";
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza -la --icons --tree --level=2";
      grep = "rg";
      py = "python3";
      nv = "doas hx";
      gc = "doas nix-collect-garbage -d && doas nix-collect-garbage --delete-old && nix store optimise";
    };
    shellAbbrs = {
      nix = "nix";
      flake = "nix flake";
    };
  };
}
