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
