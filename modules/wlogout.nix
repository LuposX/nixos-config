{ config, lib, pkgs, vars, ... }:
{
  
  environment.systemPackages = with pkgs; [
    wlogout
  ];

 
  home-manager.users.${vars.user} = {
    xdg.configFile."wlogout".source = ./wlogout;   
  };
}
