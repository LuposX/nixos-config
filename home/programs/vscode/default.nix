{pkgs, ...}: {
  # VSCodium. Uses the dedicated home-manager module so extensions and
  # settings land in ~/.vscode-oss and ~/.config/VSCodium.
  programs.vscodium = {
    enable = true;
    package = pkgs.vscodium;
    # https://github.com/nix-community/nix-vscode-extensions/blob/master/data/cache/open-vsx-latest.json
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      bbenoist.nix
      leanprover.lean4
      tamasfe.even-better-toml # hard dependency of the lean4 extension
      ms-python.python
      mechatroner.rainbow-csv
      shardulm94.trailing-spaces
      esbenp.prettier-vscode
      redhat.vscode-yaml
      mhutchie.git-graph
    ];
    profiles.default.userSettings = {
      "workbench.colorTheme" = "Default Dark Modern";
      "editor.fontFamily" = "JetBrains Mono Nerd Font";
      "editor.fontSize" = 13;
      "editor.lineHeight" = 19;
      "workbench.list.fontSize" = 9;

      "vim.useSystemClipboard" = true;

      # Prevent "Unable to watch for file changes" error on large workspaces
      "files.watcherExclude" = {
        "**/.git/objects/**" = true;
        "**/.git/subtree-cache/**" = true;
        "**/node_modules/**" = true;
        "**/.venv/**" = true;
        "**/__pycache__/**" = true;
        "**/target/**" = true;
        "**/_build/**" = true;
        "**/.direnv/**" = true;
        "**/dist/**" = true;
        "**/.next/**" = true;
        "**/.lake/**" = true;
      };

      "lean4.input.eagerReplacementEnabled" = true;
      "lean4.infoview.stickyPosition" = "all";
    };
  };
}