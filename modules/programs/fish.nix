{ pkgs, config, ... }: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      zoxide init fish | source

      function gitwho
        echo (git config user.name) '<'(git config user.email)'>'
      end

      function upgrade
        set -l CACHE_DIR ~/.cache/update
        mkdir -p $CACHE_DIR
        nix flake update $CACHE_DIR/../..
        sudo nixos-rebuild switch --flake $CACHE_DIR/../.. -j(math (nproc) / 2)
      end
    '';
    shellAliases = {
      cat = "bat -p";
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza -la --icons --tree --level=2";
      grep = "rg";
      py = "python3";
      sv = "sudo nvim";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gs = "git status";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      gl = "git log --oneline --graph";
      nrs = "sudo nixos-rebuild switch --flake ${config.vars.flakeDir}#${config.vars.hostname} -j(math (nproc) / 2)";
      nrb = "sudo nixos-rebuild boot --flake ${config.vars.flakeDir}#${config.vars.hostname} -j(math (nproc) / 2)";
      nrt = "sudo nixos-rebuild test --flake ${config.vars.flakeDir}#${config.vars.hostname} -j(math (nproc) / 2)";
      update = "nix flake update ${config.vars.flakeDir}";
      sysupd = "sudo nixos-rebuild switch --flake ${config.vars.flakeDir}#${config.vars.hostname} -j(math (nproc) / 2)";
      nixgc = "sudo nix-collect-garbage -d";
      clean = "sudo nix-collect-garbage -d && sudo nix-collect-garbage --delete-old && nix store optimise";
    };
    shellAbbrs = {
      nix = "nix";
      flake = "nix flake";
    };
  };
}
