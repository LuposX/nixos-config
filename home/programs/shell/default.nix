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
  ];

  home.packages = with pkgs; [
    bat
    fd
    file # Required for fzf file preview
    nerdfetch
  ];
}
