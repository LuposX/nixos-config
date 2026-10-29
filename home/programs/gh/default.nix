# GitHub CLI: gh for issues/PRs, plus git credential helper for github.com
{...}: {
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "";
      prompt = "enabled";
    };
  };
}
