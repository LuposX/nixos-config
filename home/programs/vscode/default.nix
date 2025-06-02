{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
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
  };
}