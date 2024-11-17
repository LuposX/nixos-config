{inputs, pkgs, config, ... }:

{
  imports = [
    ./firefox.nix
    ./desktop.nix
    ./zsh.nix
    ./doom-emacs.nix
    ./login.nix
    ./foot.nix
  ];
}
