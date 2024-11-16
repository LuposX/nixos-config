{ config, lib, pkgs, vars, ... }:
{
  
  environment.systemPackages = with pkgs; [
    playerctl
    pavucontrol
  ];

  programs.waybar = {
    enable = true;
  };

  fonts.packages = with pkgs; [
    font-awesome
    roboto-mono
  ];
  
  home-manager.users.${vars.user} = {
    programs.waybar.enable = true;
    
    # Takesn from: harsh-m-patil/.dotfiles
    xdg.configFile."waybar".source = ./waybar;  
  };
}
