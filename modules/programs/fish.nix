{ pkgs, config, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
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
        set -g __last_dir "$PWD"
        builtin cd $argv
      end

      function gp
        git add .
        git commit -m "$argv"
        git push
      end

      function sysupd
        nix flake update
        nh os switch ".#$argv"
      end

      function update
        nh os switch ".#$argv"
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

      # ── devenv helpers ──────────────────────────────
      set DEVENV_ROOT ~/nixos-cfg/devenvs

      function env-shell
        if test -z "$argv[1]"
          echo "Usage: env-shell <language>"
          echo "Available: rust go python cc zig haskell lua ocaml bash-stack"
          return 1
        end
        set dir $DEVENV_ROOT/$argv[1]
        if not test -d "$dir"
          echo "Unknown devenv: $argv[1]"
          return 1
        end
        pushd "$dir"
        devenv shell
        popd
      end

      function env-up
        if test -z "$argv[1]"
          echo "Usage: env-up <language>"
          return 1
        end
        set dir $DEVENV_ROOT/$argv[1]
        if not test -d "$dir"
          echo "Unknown devenv: $argv[1]"
          return 1
        end
        pushd "$dir"
        devenv up
        popd
      end

      for lang in rust go python cc zig haskell lua ocaml bash-stack
        eval "
          function env-$lang
            env-shell $lang
          end
        "
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
