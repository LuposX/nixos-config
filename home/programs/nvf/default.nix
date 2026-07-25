# Source: https://github.com/JaKooLit/Ja-ZaneyOS/blob/ja-edited/modules/home/nvf.nix
# For options see: https://notashelf.github.io/nvf/options
{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [ inputs.nvf.homeManagerModules.default ];

  programs.nvf = {
    enable = true;

    settings.vim = {
      vimAlias = true;
      viAlias = true;

      undoFile.enable = true; # Persist undo history across sessions
      preventJunkFiles = true; # Disable swap and backup files
      searchCase = "smart";

      git = {
        enable = true;
        # Gitsigns disabled — user doesn't use inline diff markers
        gitsigns.enable = false;
        # Git-conflict disabled — user handles merges externally
        git-conflict.enable = false;
      };

      clipboard = {
        enable = true;
        registers = "unnamedplus";

        providers = {
          wl-copy.enable = true;
        };
      };

      options = {
        tabstop = 2;
        shiftwidth = 2;
        wrap = true;
      };

      spellcheck = {
        enable = true;
        languages = [ "en" ];
      };

      lsp = {
        enable = true;
        formatOnSave = true;
        trouble.enable = true;
        lightbulb.enable = true;
        lspSignature.enable = true;
        null-ls.enable = true;
        otter-nvim = {
          enable = true;
          setupOpts.buffers.write_to_disk = true;
        };
      };


      languages = {
        enableFormat = true;
        enableTreesitter = false; # Disable treesitter due to nvf parsers incompatibility
        enableExtraDiagnostics = true;

        nix.enable = true;
        markdown.enable = false; # marksman LSP requires dotnet to build
        bash.enable = true;
        yaml.enable = true;
        python.enable = true;
        html.enable = true;
        json.enable = true;
        css.enable = true;

        # LaTeX support: texlab LSP + treesitter + formatters.
        # TeXpresso handles live rendering, so treesitter is left disabled
        # (follows global enableTreesitter = false)
        tex = {
          enable = true;
        };
      };

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      comments.comment-nvim.enable = true;
      autopairs.nvim-autopairs.enable = true;
      autocomplete.nvim-cmp.enable = true;
      dashboard.dashboard-nvim.enable = true;
      statusline.lualine.enable = true;
      treesitter.enable = true;

      snippets.luasnip.enable = true;

      telescope = {
        enable = true;
        mappings = {
          findFiles = "<leader>sf";
          liveGrep = "<leader>sg";
          diagnostics = "<leader>se";
          buffers = "<leader>sb";
          resume = "<leader>sr";
          gitBranches = "<leader>gb";
          gitBufferCommits = "<leader>gcb";
          gitCommits = "<leader>gc";
          gitStatus = "<leader>gs";
        };
      };

      utility = {
        # To Go up a directory press "-a"
        # When in oil mode press "g"
        oil-nvim.enable = true;
        oil-nvim.gitStatus.enable = true;

         preview.markdownPreview = {
            enable = true;
            autoStart = true;
            autoClose = true;
          };

          images = {
            image-nvim.enable = false;
          };
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        smartcolumn.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;
        fastaction.enable = true;
        breadcrumbs = {
          enable = false;
          navbuddy.enable = false;
        };
      };

      visuals = {
        nvim-web-devicons.enable = true;
        highlight-undo.enable = true;
        indent-blankline.enable = true;
      };

      # ── LaTeX: TeXpresso Plugin ────────────────────────────────
      # Provides live rendering and error reporting for LaTeX.
      # Start with `:TeXpresso %` on your root .tex file.
      # The texpresso binary must be in PATH (added as a system package).
      # Docs: https://github.com/let-def/texpresso.vim
      startPlugins = [ pkgs.vimPlugins.texpresso-vim ];

      # ── Which-key: group names for all categories ────────────
      # Each first-level prefix gets a human-readable label.
      # This registers descriptions for the which-key popup when you press <leader>.
      luaConfigPost = ''
        local wk = require("which-key")
        wk.add({
          { "<leader>c", group = "Conflict" },   -- git-conflict
          { "<leader>f", group = "Find" },       -- telescope file finding
          { "<leader>g", group = "Git" },        -- telescope git / fugitive
          { "<leader>h", group = "Hunks" },      -- gitsigns
          { "<leader>l", group = "LSP" },        -- code action, diagnostic, format
          { "<leader>p", group = "Preview" },    -- TeXpresso / live rendering
          { "<leader>s", group = "Search" },     -- telescope grep/buffers
          { "<leader>t", group = "Hunks" },      -- gitsigns (toggle)
          { "<leader>x", group = "Trouble" },    -- trouble diagnostics
        })
      '';

      # ── Notes ────────────────────────────────────────────────
      # 1. "Code action not supported" on LaTeX — this is a texlab LSP
      #    limitation. texlab does NOT implement textDocument/codeAction.
      #    Only the LSP servers that support it will show code actions.
      # 2. Trouble / quickfix "no results" — no diagnostics were emitted.
      #    For LaTeX, texlab only populates diagnostics after a compile
      #    (e.g. via TeXpresso or latexmk). A clean file = empty list.

      keymaps = [
        # ── File navigation ──────────────────────────────────
        {
          key = "<leader>o";
          mode = "n";
          action = ":Oil --float <CR>";
          desc = "Oil file manager";
        }
        # ── TeXpresso (grouped under <leader>p) ────────────────
        {
          key = "<leader>pp";
          mode = "n";
          action = ":TeXpresso %<CR>";
          desc = "Launch TeXpresso live preview";
        }
        {
          key = "<leader>pq";
          mode = "n";
          action = ":TeXpresso stop<CR>";
          desc = "Stop TeXpresso";
        }
      ];

    };
  };
}
