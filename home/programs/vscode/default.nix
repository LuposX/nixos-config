{pkgs, ...}: {
  stylix.targets.vscode.fonts.enable = false;
  stylix.targets.vscode.colors.enable = true;
  stylix.targets.vscode.enable = true;
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    # https://github.com/nix-community/nix-vscode-extensions/blob/master/data/cache/open-vsx-latest.json
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      bbenoist.nix
      ms-python.python
      mechatroner.rainbow-csv
      shardulm94.trailing-spaces
      esbenp.prettier-vscode
      redhat.vscode-yaml
      mhutchie.git-graph
    ];
    profiles.default.userSettings = {
      "workbench.colorTheme" = "Stylix";
      "editor.fontFamily" = "JetBrains Mono Nerd Font";
      "editor.fontSize" = 13;
      "editor.lineHeight" = 19;
      "workbench.list.fontSize" = 9;
    };
  };
}