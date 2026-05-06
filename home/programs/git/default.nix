# Git configuration
{ config, ... }:
let
  username = config.var.git.username;
  email = config.var.git.email;
in {
  programs.git = {
  enable = true;

  settings = {
    user = {
      name = username;
      email = email;
    };

    init.defaultBranch = "main";
    pull.rebase = false;
    push.autoSetupRemote = true;
    color.ui = 1;
  };

  ignores = [
    ".cache/"
    ".DS_Store"
    ".idea/"
    "*.swp"
    "*.elc"
    "auto-save-list"
    ".direnv/"
    "node_modules"
    "result"
    "result-*"
  ];
};
}
