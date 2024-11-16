{ config, lib, pkgs, vars, ... }:

{
  environment.systemPackages = with pkgs; [
    foot
  ]
;
  fonts.packages = with pkgs; [
     jetbrains-mono
     # For Nerdfonts
     (nerdfonts.override {
     fonts = [
       "FiraCode"
       "Hack"
     ];
    })
  ];

  home-manager.users.${vars.user} = {
    programs.foot = { 
      enable = true;
      settings.main.font = "Jetbrains Mono:size=13"; # Use 'fl-match' to check
    };
  };
}
