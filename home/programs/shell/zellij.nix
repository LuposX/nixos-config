{ pkgs, ... }:
{
  # If you get error when creating new session try to delte the cahce
  # $HOME/.cache/zellij
  # See https://github.com/NixOS/nixpkgs/issues/216961
  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # default_layout = "compact";
      show_startup_tips = false;
      show_release_notes = false;
      # on_force_close = "quit";
    };
  };
}
