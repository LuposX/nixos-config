# Fzf is a general-purpose command-line fuzzy finder.
{ config, lib, ... }: {
  programs.fzf = {
    enable = true;
    enableFishIntegration = false; # We instead use the fish plugin
  };
}
