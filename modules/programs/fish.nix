{ pkgs, config, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -gx LIBVIRT_DEFAULT_URI qemu:///system
      set -g fish_greeting

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

      function endtor
        doas pkill -9 -x tor 2>/dev/null
        or doas kill -9 (pgrep -x tor 2>/dev/null) 2>/dev/null
        echo "tor killed"
      end

      function iftor
        if curl -sL --socks5 127.0.0.1:9050 https://check.torproject.org/ | rg -q "Congratulations"
          echo "Connected to the internet via tor"
        else
          echo "Not connected to the internet via tor"
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

      function tor --wraps tor --description 'Start tor daemon in background'
        command tor -f ~/.torrc $argv &
        disown
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
      nv = "doas nvim";
      gc = "doas nix-collect-garbage -d && doas nix-collect-garbage --delete-old && nix store optimise";
    };
    shellAbbrs = {
      nix = "nix";
      flake = "nix flake";
    };
  };
}
