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
        # VimTeX handles compilation (via latexmk — lualatex engine).
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

      # ── LaTeX: VimTeX Plugin ────────────────────────────────────
      # VimTeX handles compilation (via latexmk), text objects, motions,
      # and PDF viewer integration. Default compiler: latexmk.
      # Continous mode: :VimtexCompile — recompiles on every :w.
      # Single-shot:   :VimtexCompileSS — one-off compile.
      startPlugins = [ pkgs.vimPlugins.vimtex ];

      # ── Lua config (vimtex + which-key) ─────────────────────
      # VimTeX uses texpresso for live rendering.
      # The texpresso binary is available via the system environment.
      luaConfigPost = ''
        -- VimTeX compiler: texpresso (live incremental preview)
        vim.g.vimtex_compiler_method = 'texpresso'

        -- Which-key: group labels
        local wk = require("which-key")
        wk.add({
          { "<leader>c", group = "Conflict" },   -- git-conflict
          { "<leader>f", group = "Find" },       -- telescope file finding
          { "<leader>g", group = "Git" },        -- telescope git / fugitive
          { "<leader>h", group = "Hunks" },      -- gitsigns
          { "<leader>p", group = "LaTeX" },      -- VimTeX compile / clean
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
      #    (e.g. via :VimtexCompile). A clean file = empty list.
      # 3. texpresso renders incrementally — no build/ subfolder needed.
      #    For a final / presentation-ready PDF, use <leader>pf which runs
      #    latexmk directly (lualatex, aux in build/, PDF in project root).
      #    The texpresso binary must be in PATH (provided by system packages).

      keymaps = [
        # ── File navigation ──────────────────────────────────
        {
          key = "<leader>o";
          mode = "n";
          action = ":Oil --float <CR>";
          desc = "Oil file manager";
        }
        # ── LaTeX / VimTeX (grouped under <leader>p) ────────────────
        # All mirrors of vimtex's default <localleader>l* mappings
        {
          key = "<leader>pi";
          mode = "n";
          action = ":VimtexInfo<CR>";
          desc = "VimTeX info";
        }
        {
          key = "<leader>pt";
          mode = "n";
          action = ":VimtexTocOpen<CR>";
          desc = "Open TOC";
        }
        {
          key = "<leader>pT";
          mode = "n";
          action = ":VimtexTocToggle<CR>";
          desc = "Toggle TOC";
        }
        {
          key = "<leader>pq";
          mode = "n";
          action = ":VimtexLog<CR>";
          desc = "Open log";
        }
        {
          key = "<leader>pv";
          mode = "n";
          action = ":VimtexView<CR>";
          desc = "View PDF";
        }
        {
          key = "<leader>pl";
          mode = "n";
          action = ":VimtexCompile<CR>";
          desc = "Continuous compile";
        }
        {
          key = "<leader>pL";
          mode = "n";
          action = ":VimtexCompileSelected<CR>";
          desc = "Compile selected";
        }
        {
          key = "<leader>pS";
          mode = "n";
          action = ":VimtexCompileSS<CR>";
          desc = "Single-shot compile";
        }
        {
          key = "<leader>pk";
          mode = "n";
          action = ":VimtexStop<CR>";
          desc = "Stop compilation";
        }
        {
          key = "<leader>pe";
          mode = "n";
          action = ":VimtexErrors<CR>";
          desc = "Show errors";
        }
        {
          key = "<leader>pc";
          mode = "n";
          action = ":VimtexClean<CR>";
          desc = "Clean artifacts";
        }
        {
          key = "<leader>pC";
          mode = "n";
          action = ":VimtexCleanFull<CR>";
          desc = "Clean all (incl. PDF)";
        }
        {
          key = "<leader>px";
          mode = "n";
          action = ":VimtexReload<CR>";
          desc = "Reload VimTeX";
        }
        {
          key = "<leader>pX";
          mode = "n";
          action = ":VimtexReloadState<CR>";
          desc = "Reload state";
        }
        {
          key = "<leader>ps";
          mode = "n";
          action = ":VimtexToggleMain<CR>";
          desc = "Toggle main file";
        }
        {
          key = "<leader>pa";
          mode = "n";
          action = ":VimtexContextMenu<CR>";
          desc = "Context menu";
        }
        {
          key = "<leader>pf";
          mode = "n";
          action = ":!latexmk -lualatex -auxdir=build -pdf -verbose %<CR>";
          desc = "Final PDF (aux → build/, PDF here)";
        }
      ];

    };
  };
}
