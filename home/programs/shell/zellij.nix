{ pkgs, ... }:
{
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      default_layout = "compact";
      show_startup_tips = false;
      show_release_notes = false;
      welcome = true;
    };
  };
}
