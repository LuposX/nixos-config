{ config, lib, pkgs, vars, ... }:
{
  
  environment.systemPackages = with pkgs; [
    dunst
  ];

  fonts.packages = with pkgs; [
    jetbrains-mono
  ];
  
  home-manager.users.${vars.user} = {
    services.dunst = {
      enable = true;
      settings = {
        global = {
          font = "JetBrainsMono Nerd Font 10";
          allow_markup = yes;
          format = "<b>%s</b>\n%b";
          sort = yes;
          indicate_hidden = yes;
          bounce_freq = 0;
          show_age_threshold = 60;
          word_wrap = yes;
          ignore_newline = n;o
	  geometry = "200x5-6+30;"
	  transparency = 0;
	  # Don't timeout notification is user is idle for this amount of time, potentially useful
	  idle_threshold = 0;
	  monitor = 0;
	  follow = mouse;
	  sticky_history = yes;
	  line_height = 0;
	  timeout = 5;
	  separator_height = 2;
	  padding = 4;
	  horizontal_padding = 4;
	  # https://github.com/knopwob/dunst/issues/26#issuecomment-36159395
	  icon_position = left;
	  # icon_folders = ~/.icons/16x16/
        };
      };
    };   
  };
}
