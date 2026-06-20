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
