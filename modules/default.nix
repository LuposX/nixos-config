{inputs, pkgs, config, ... }:

{
  imports = [
    ./firefox.nix
    ./hyprland.nix
    ./zsh.nix
    ./doom-emacs.nix
    ./login.nix
    ./waybar.nix
    ./rofi.nix
    ./foot.nix
    #./hyprpanel.nix
    ./wllogout.nix
  ];
}
