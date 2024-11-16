# The Menu launcher
{ pkgs, vars, ... }:
{
  environment.systemPackages = with pkgs; [
    rofi-wayland
  ];

  home-manager.users.${vars.user} = {
    xdg.configFile."rofi".source = ./rofi;  
  };
}
