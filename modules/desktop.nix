{ inputs, pkgs-stable, config, lib, hyprland, hyprpanel, hyprspace, pkgs, vars, ... }:

{ 
  # Based on: https://github.com/zDyanTB/HyprNova

  programs.hyprland.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  
  environment.systemPackages = with pkgs; [
    rofi-wayland
    swaynotificationcenter # SwayNC
    wlogout
    pywal # Generates color templates based on wallpaper
    hyprlock
    hypridle
    python311
    kitty
    gnomeExtensions.system-monitor # Used in waybar
    wireplumber # Used in waybar
    playerctl # Used in waybar
    networkmanagerapplet
  ];

  environment.systemPackages = with pkgs-stable; [
     cava # Visualize sound
  ];

  services.hypridle.enable = true;
  programs.hyprlock.enable = true;
  programs.hyprland.portalPackage = pkgs.xdg-desktop-portal-hyprland;
  security.pam.services.hyprlock = {};

  home-manager.users.${vars.user} = {
    # Configs
    xdg.configFile."hypr".source = ./hypr;
    xdg.configFile."rofi".source = ./rofi;
    xdg.configFile."swaync".source = ./rofi;
    xdg.configFile."waybar".source = ./waybar;
    xdg.configFile."wlogout".source = ./rofi;

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
  };
}
