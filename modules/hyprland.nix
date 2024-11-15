{ config, lib, pkgs, vars, ... }:

{ 
  programs.hyprland.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  
  environment.systemPackages = with pkgs; [
    grimblast    # Screenshot
    # hyprcursor   # Cursor
    hyprpaper    # Wallpaper
    wl-clipboard # Clipboard
    wlr-randr    # Monitor Settings
    nwg-look
    kitty
    alacritty
    cliphist
    networkmanagerapplet
  ];

  services.hypridle.enable = true;
  programs.hyprlock.enable = true;
  programs.hyprland.portalPackage = pkgs.xdg-desktop-portal-hyprland;
  security.pam.services.hyprlock = {};

  home-manager.users.${vars.user} = {
    # Cursor
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
    };

    gtk = {
      enable = true;
      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };
    
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
   };

   # Config for: Hyprland, Hyprlock, ...
   xdg.configFile."hypr".source = ./hypr;  
  };
}
