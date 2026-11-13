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

        # Typst support: tinymist LSP + treesitter + typstyle formatter.
        # The browser-based preview is disabled on purpose; compilation is
        # done by tinymist compile from the <leader>pl keymap, which writes
        # into <dir>/build/ instead of next to the source.
        typst = {
          enable = true;
          treesitter.enable = true;
          format.enable = true;
          extensions.typst-preview-nvim.enable = false;
        };

        # Java: jdt-language-server LSP + treesitter + astyle format +
        # Maven/Gradle integration. The jdt-language-server needs a JDK on
        # the PATH — see home/programs/java for the JDK/maven/gradle/sat4j
        # packages.
        java = {
          enable = true;
          format.enable = true;
          extensions = {
            maven-nvim.enable = true;
            gradle-nvim.enable = true;
          };
        };
      };

      # Keep the LSP out of the PDF business: it would drop <name>.pdf next
      # to the .typ on every save. The compile keymap handles that instead.
      lsp.servers.tinymist.settings.exportPdf = "never";

      formatter.conform-nvim.presets.typstyle.enable = true;

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      comments.comment-nvim.enable = true;
      autopairs.nvim-autopairs.enable = true;
      autocomplete.nvim-cmp.enable = true;
      dashboard.dashboard-nvim.enable = true;
      # breadcrumbs moved here from vim.ui.breadcrumbs in nvf
      statusline.lualine = {
        enable = true;
        integrations.breadcrumbs = {
          nvim-navic.enable = false;
          navbuddy.enable = false;
        };
      };
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

        undotree.enable = true;

        # Disabled: it auto-started a localhost browser preview on every
        # markdown file. Start it manually with :MarkdownPreview if needed.
        preview.markdownPreview = {
          enable = false;
          autoStart = false;
          autoClose = false;
        };

         images = {
           image-nvim.enable = false;
         };
      };

      notes.todo-comments.enable = true;

      ui = {
        borders.enable = true;
        noice.enable = true;
        smartcolumn.enable = true;
        colorizer.enable = true;
        illuminate.enable = true;
        fastaction.enable = true;
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
      # Viewer: sioyek. Do NOT switch back to texpresso as compiler —
      # it renders in its own embedded MuPDF/SDL window and ignores
      # vimtex_view_method, so sioyek would never open.
      luaConfigPost = ''
        -- VimTeX compiler: latexmk (lualatex, synctex, build/)
        vim.g.vimtex_compiler_method = 'latexmk'
        vim.g.vimtex_compiler_latexmk = {
          aux_dir = 'build',
          out_dir = 'build',
          callback = 1,
          continuous = 1,
          executable = 'latexmk',
          options = {
            '-verbose',
            '-file-line-error',
            '-synctex=1',
            '-interaction=nonstopmode',
          },
        }
        vim.g.vimtex_compiler_latexmk_engines = {
          ['_'] = '-lualatex',
        }

        -- VimTeX viewer: sioyek (forward search via synctex)
        vim.g.vimtex_view_method = 'sioyek'

        -- ── Typst: PDF viewer workflow (mirrors VimTeX) ────────
        -- Compile output goes to <dir>/build/<name>.pdf so the source tree
        -- stays clean. --reuse-window reuses an already open sioyek instead
        -- of spawning a second one; sioyek reloads the PDF when the file
        -- changes on disk.
        local typst_bin = '${pkgs.lib.getExe pkgs.tinymist}'
        local typst_viewer = '${pkgs.lib.getExe pkgs.sioyek}'

        -- A typst.toml above the file marks the project root, otherwise the
        -- file's own directory is used (what `typst compile` does from there).
        -- Deliberately not the git root: a typst project nested in a larger
        -- repo would resolve "/lib/x.typ" imports against the wrong tree.
        local function typst_root(dir)
          local current = dir
          while current do
            if vim.fn.filereadable(current .. '/typst.toml') == 1 then
              return current
            end
            local parent = vim.fn.fnamemodify(current, ':h')
            if parent == current then break end
            current = parent
          end
          return dir
        end

        -- [package] entrypoint from typst.toml, if the project declares one.
        local function typst_entrypoint(root)
          local toml = root .. '/typst.toml'
          if vim.fn.filereadable(toml) == 0 then return nil end
          local in_package = false
          for _, line in ipairs(vim.fn.readfile(toml)) do
            if line:match('^%s*%[') then
              in_package = line:match('^%s*%[%s*package%s*%]') ~= nil
            elseif in_package then
              local entry = line:match('^%s*entrypoint%s*=%s*["\']([^"\']+)["\']')
              if entry then
                local path = vim.fn.fnamemodify(root .. '/' .. entry, ':p')
                if vim.fn.filereadable(path) == 1 then return path end
              end
            end
          end
          return nil
        end

        -- Without typst.toml, a fragment like prayers.typ is compiled through
        -- the sibling that #includes it, as long as exactly one does.
        local function typst_includer(src, dir)
          local base = vim.fn.fnamemodify(src, ':t')
          local matches = {}
          for _, candidate in ipairs(vim.fn.glob(dir .. '/*.typ', false, true)) do
            if vim.fn.fnamemodify(candidate, ':p') ~= src then
              for _, line in ipairs(vim.fn.readfile(candidate)) do
                if line:match('^%s*#%s*include%s+"' .. vim.pesc(base) .. '"') then
                  table.insert(matches, candidate)
                  break
                end
              end
            end
          end
          if #matches == 1 then return matches[1] end
          return nil
        end

        -- Compiling a fragment on its own fails (helpers live in the book),
        -- so resolve the file that actually produces a document.
        local function typst_main(src, dir, root)
          return typst_entrypoint(root) or typst_includer(src, dir) or src
        end

        -- Returns source file, project root, main file, PDF path.
        local function typst_paths()
          local src = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p')
          local dir = vim.fn.fnamemodify(src, ':h')
          local root = typst_root(dir)
          local main = typst_main(src, dir, root)
          local pdf = vim.fn.fnamemodify(main, ':h')
            .. '/build/' .. vim.fn.fnamemodify(main, ':t:r') .. '.pdf'
          return src, root, main, pdf
        end

        local function typst_open(pdf)
          if vim.fn.filereadable(pdf) == 0 then
            vim.notify('Typst: no PDF at ' .. vim.fn.fnamemodify(pdf, ':~:.'), vim.log.levels.WARN)
            return
          end
          vim.system({ typst_viewer, '--reuse-window', pdf }, { detach = true })
        end

        local function typst_compile(on_done)
          local _, root, main, pdf = typst_paths()
          vim.fn.mkdir(vim.fn.fnamemodify(pdf, ':h'), 'p')
          vim.system(
            { typst_bin, 'compile', '--root', root, main, pdf },
            { text = true, cwd = root },
            function(res)
              vim.schedule(function()
                if res.code ~= 0 then
                  local err = vim.trim(res.stderr or "")
                  vim.notify('Typst: ' .. (err ~= "" and err or 'compile failed'), vim.log.levels.ERROR)
                  return
                end
                on_done(pdf)
              end)
            end
          )
        end

        function _G.nvf_typst_compile()
          if vim.api.nvim_buf_get_name(0) == "" then
            vim.notify('Typst: save the buffer first', vim.log.levels.WARN)
            return
          end
          vim.cmd('silent write')
          typst_compile(typst_open)
        end

        -- Compile only, no viewer (for CI-ish checks or a quiet rebuild).
        function _G.nvf_typst_export()
          if vim.api.nvim_buf_get_name(0) == "" then
            vim.notify('Typst: save the buffer first', vim.log.levels.WARN)
            return
          end
          vim.cmd('silent write')
          typst_compile(function(pdf)
            vim.notify('Typst: wrote ' .. vim.fn.fnamemodify(pdf, ':~:.'), vim.log.levels.INFO)
          end)
        end

        function _G.nvf_view_pdf()
          if vim.bo.filetype == 'typst' then
            local _, _, _, pdf = typst_paths()
            typst_open(pdf)
          else
            vim.cmd('VimtexView')
          end
        end

        function _G.nvf_compile_pdf()
          if vim.bo.filetype == 'typst' then
            _G.nvf_typst_compile()
          else
            vim.cmd('VimtexCompile')
          end
        end

        -- Which-key: group labels
        local wk = require("which-key")
        wk.add({
          { "<leader>c", group = "Conflict" },   -- git-conflict
          { "<leader>f", group = "Find" },       -- telescope file finding
          { "<leader>g", group = "Git" },        -- telescope git / fugitive
          { "<leader>j", group = "Java" },       -- maven / gradle
          { "<leader>h", group = "Hunks" },      -- gitsigns
          { "<leader>p", group = "LaTeX / Typst" },      -- VimTeX + tinymist
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
      # 3. latexmk output goes to build/ (aux_dir + out_dir). <leader>pv
      #    opens the PDF in sioyek with forward search; sioyek auto-reloads
      #    on recompile.
      # 4. Typst: tinymist LSP provides completion, diagnostics, formatting.
      #    LSP-side PDF export is off (exportPdf = never) so nothing lands
      #    next to the sources. <leader>pl saves, runs `tinymist compile`
      #    into <dir>/build/<name>.pdf and opens it in sioyek; <leader>pv
      #    only reopens the last build. Recompiling while sioyek is open is
      #    fine, it reloads the PDF from disk.
      # 5. Typst fragments: `#include` does not share the includer's scope,
      #    so compiling prayers.typ on its own reports every helper as an
      #    unknown variable. The compile keymap therefore builds the main
      #    file instead: [package] entrypoint from typst.toml if declared,
      #    otherwise the one sibling that #includes the current file.

      keymaps = [
        # ── File navigation ──────────────────────────────────
        {
          key = "<leader>o";
          mode = "n";
          action = ":Oil --float <CR>";
          desc = "Oil file manager";
        }
        # ── Window navigation (Ctrl+{h,j,k,l}) ─────────────────────
        {
          key = "<C-h>";
          mode = "n";
          action = "<C-w>h";
          desc = "Window left";
        }
        {
          key = "<C-j>";
          mode = "n";
          action = "<C-w>j";
          desc = "Window down";
        }
        {
          key = "<C-k>";
          mode = "n";
          action = "<C-w>k";
          desc = "Window up";
        }
        {
          key = "<C-l>";
          mode = "n";
          action = "<C-w>l";
          desc = "Window right";
        }
        # ── LaTeX / VimTeX (grouped under <leader>p) ────────────────
        {
          key = "<leader>pi";
          mode = "n";
          action = ":VimtexInfo<CR>";
          desc = "VimTeX info";
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
          action = ":lua nvf_view_pdf()<CR>";
          desc = "View PDF (LaTeX / Typst)";
        }
        {
          key = "<leader>pl";
          mode = "n";
          action = ":lua nvf_compile_pdf()<CR>";
          desc = "Compile + view (LaTeX / Typst)";
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
        # ── Typst (grouped under <leader>p) ─────────────────────────
        # <leader>pl / <leader>pv are shared with VimTeX and dispatch on
        # filetype; this one is a Typst-only extra.
        {
          key = "<leader>pf";
          mode = "n";
          action = ":lua nvf_typst_export()<CR>";
          desc = "Compile Typst (no viewer)";
        }
      ];

    };
  };
}
