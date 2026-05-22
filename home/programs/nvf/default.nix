# Source: https://github.com/JaKooLit/Ja-ZaneyOS/blob/ja-edited/modules/home/nvf.nix
# For otpions see: https://notashelf.github.io/nvf/options
{
  inputs,
  config,
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

      git.enable = true;

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

      keymaps = [
        {
          key = "<leader>o";
          mode = "n";
          action = ":Oil --float <CR>";
        }
      ];

    };
  };
}
