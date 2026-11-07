{
  rum.programs.helix = {
    enable = true;

    settings = {
      theme = "catppuccin_mocha";

      editor = {
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        true-color = true;
        scrolloff = 8;
        rulers = [
          80
          120
        ];
        soft-wrap.enable = false;
        indent-guides = {
          render = true;
          character = "╎";
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
        statusline = {
          left = [
            "mode"
            "version-control"
          ];
          center = [ "file-name" ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
          ];
        };
      };

      keys = {
        normal."C-s" = ":w";
        insert."C-s" = ":w";
      };
    };

    languages = {
      language-server = {
        asm-lsp.command = "asm-lsp";
        ols.command = "ols";
        hare-lsp = {
          command = "hare-lsp";
          args = [ "-S" ];
        };
      };

      language = [
        {
          name = "hare";
          scope = "source.hare";
          grammar = "hare";
          file-types = [ "ha" ];
          roots = [ "hare.toml" ];
          language-servers = [ "hare-lsp" ];
        }
        {
          name = "asm";
          scope = "source.asm";
          grammar = "asm";
          file-types = [
            "asm"
            "s"
            "S"
            "fasm"
          ];
          language-servers = [ "asm-lsp" ];
        }
        {
          name = "odin";
          scope = "source.odin";
          file-types = [ "odin" ];
          language-servers = [ "ols" ];
        }
        {
          name = "nix";
          scope = "source.nix";
          auto-format = true;
          formatter.command = "nixfmt";
        }
        {
          name = "rust";
          scope = "source.rust";
          auto-format = true;
        }
      ];
    };
  };
}
