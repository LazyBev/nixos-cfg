{ pkgs, ... }: {
  programs.nvf = {
    enable = true;
    settings.vim = {
      viAlias = false;
      vimAlias = true;
      enableLuaLoader = true;
      extraPackages = with pkgs; [
        wl-clipboard
        nil
      ];
      opts = {
        number = true;
        relativenumber = true;
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
        mouse = "a";
        termguicolors = true;
        updatetime = 50;
        scrolloff = 8;
        signcolumn = "yes";
        smartcase = true;
        ignorecase = true;
        splitright = true;
        splitbelow = true;
        undofile = true;
        wrap = false;
        cursorline = true;
        clipboard = "unnamedplus";
      };
      theme = { enable = true; name = "dracula"; };
      lsp = {
        enable = true;
        formatOnSave = true;
        lightbulb.enable = true;
        trouble.enable = true;
        lspSignature.enable = true;
        mappings = {
          goToDefinition = "gd";
          goToDeclaration = "gD";
          goToType = "<leader>D";
          listReferences = "gr";
          listImplementations = "gI";
          hover = "K";
          signatureHelp = "<C-k>";
          renameSymbol = "<leader>rn";
          codeAction = "<leader>ca";
          openDiagnosticFloat = "gl";
          nextDiagnostic = "]d";
          previousDiagnostic = "[d";
          listDocumentSymbols = "<leader>ls";
          listWorkspaceSymbols = "<leader>lS";
          format = "<leader>lf";
        };
      };
      languages = {
        enableTreesitter = true;
        enableExtraDiagnostics = true;
        enableFormat = true;
        nix.enable = true;
        markdown.enable = true;
        python.enable = true;
        rust.enable = true;
        typescript.enable = true;
        bash.enable = true;
        clang.enable = true;
        cmake.enable = true;
        go.enable = true;
        haskell.enable = true;
        lua.enable = true;
        ocaml.enable = true;
        odin.enable = true;
        zig.enable = true;
      };
      autocomplete.nvim-cmp.enable = true;
      snippets.luasnip.enable = true;
      telescope.enable = true;
      tabline.nvimBufferline.enable = true;
      filetree.neo-tree.enable = true;
      statusline.lualine = { enable = true; theme = "auto"; };
      dashboard.alpha = { enable = true; theme = "dashboard"; };
      git = { enable = true; gitsigns.enable = true; neogit.enable = true; };
      comments.comment-nvim.enable = true;
      visuals = {
        indent-blankline.enable = true;
        nvim-cursorline.enable = true;
        fidget-nvim.enable = true;
      };
      binds.whichKey = { enable = true; setupOpts.preset = "modern"; };
      ui.noice = {
        enable = true;
        setupOpts.presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = false;
          lsp_doc_border = true;
        };
      };
      notify.nvim-notify.enable = true;
      utility.motion.flash-nvim.enable = true;
      mini = {
        indentscope.enable = true;
        pairs.enable = true;
        surround.enable = true;
      };
      notes.todo-comments.enable = true;
      terminal.toggleterm = { enable = true; lazygit.enable = true; };
      luaConfigPost = ''
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local function create_file(prompt_bufnr)
          local path = action_state.get_current_line()
          if path == "" then return end
          local dir = vim.fn.fnamemodify(path, ":h")
          if dir ~= "." then vim.fn.mkdir(dir, "p") end
          actions.close(prompt_bufnr)
          vim.cmd("edit " .. vim.fn.fnameescape(path))
        end
        require("telescope").setup({
          defaults = {
            mappings = {
              i = { ["<C-e>"] = create_file },
              n = { ["<C-e>"] = create_file },
            },
          },
        })
      '';
      autocmds = [{
        event = [ "FileType" ];
        pattern = [ "alpha" ];
        command = "nnoremap <buffer> q :q<CR>";
        desc = "Quit neovim from alpha dashboard";
      }];
      keymaps = [
        { key = "<leader>w"; mode = "n"; action = "<cmd>w<CR>"; silent = true; desc = "Save file"; }
        { key = "<leader>q"; mode = "n"; action = "<cmd>q<CR>"; silent = true; desc = "Quit"; }
        { key = "<C-h>"; mode = "n"; action = "<cmd>wincmd h<CR>"; desc = "Go to left window"; }
        { key = "<C-j>"; mode = "n"; action = "<cmd>wincmd j<CR>"; desc = "Go to bottom window"; }
        { key = "<C-k>"; mode = "n"; action = "<cmd>wincmd k<CR>"; desc = "Go to top window"; }
        { key = "<C-l>"; mode = "n"; action = "<cmd>wincmd l<CR>"; desc = "Go to right window"; }
        { key = "<leader>e"; mode = "n"; action = "<cmd>Neotree toggle<CR>"; silent = true; desc = "Toggle file tree"; }
        { key = "<leader>ff"; mode = "n"; action = "<cmd>Telescope find_files<CR>"; silent = true; desc = "Find files"; }
        { key = "<leader>fg"; mode = "n"; action = "<cmd>Telescope live_grep<CR>"; silent = true; desc = "Live grep"; }
        { key = "<leader>fb"; mode = "n"; action = "<cmd>Telescope buffers<CR>"; silent = true; desc = "Find buffers"; }
        { key = "<leader>fr"; mode = "n"; action = "<cmd>Telescope resume<CR>"; silent = true; desc = "Resume telescope"; }
        { key = "<leader>gs"; mode = "n"; action = "<cmd>Neogit<CR>"; silent = true; desc = "Git status"; }
        { key = "<leader>th"; mode = "n"; action = "<cmd>Telescope help_tags<CR>"; silent = true; desc = "Find help"; }
        { key = "<leader>sr"; mode = "n"; action = "<cmd>%s///gc<Left><Left><Left>"; silent = true; desc = "Search and replace"; }
        { key = "<leader>c"; mode = "n"; action = "<cmd>nohlsearch<CR>"; silent = true; desc = "Clear search highlights"; }
        { key = "J"; mode = "n"; action = "mzJ`z"; desc = "Join lines and keep cursor"; }
        { key = "<C-up>"; mode = "n"; action = "<cmd>resize -2<CR>"; desc = "Resize split up"; }
        { key = "<C-down>"; mode = "n"; action = "<cmd>resize +2<CR>"; desc = "Resize split down"; }
        { key = "<C-left>"; mode = "n"; action = "<cmd>vertical resize -2<CR>"; desc = "Resize split left"; }
        { key = "<C-right>"; mode = "n"; action = "<cmd>vertical resize +2<CR>"; desc = "Resize split right"; }
        { key = "<leader>bb"; mode = "n"; action = "<cmd>e #<CR>"; silent = true; desc = "Switch to other buffer"; }
        { key = "<leader>?"; mode = "n"; action = "<cmd>WhichKey<CR>"; silent = true; desc = "Show all keybinds"; }
      ];
    };
  };
}
