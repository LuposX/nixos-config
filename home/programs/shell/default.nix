{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    ./eza.nix
    ./zoxide.nix
    ./fish.nix
    ./starship.nix
    ./fzf.nix
    # ./zellij.nix
    ./direnv.nix
  ];

  home.packages = with pkgs; [
    bat
    fd
    file # Required for fzf file preview
    jq   # Required by done.fish plugin for niri window focus checks
    nerdfetch
  ];
}
