{
  lib,
  pkgs,
  config,
  ...
}: let
  configDirectory = config.var.configDirectory;
in {
  options.theme = lib.mkOption {
    type = lib.types.attrs;
    default = {
      rounding = 20;

      # Name of the profile picture, put it in the resources folder.
      profile-picture-name = "monke_wide.jpg";

      niri = {
        layout = {
          background-color = "transparent";
          focus-ring = {
            enable = true;
            width = 3;
            active = {
              color = "#A8AEFF";
            };
            inactive = {
              color = "#505050";
            };
          };
          gaps = 0;
          struts = {
            left = 0;
            right = 0;
            top = 0;
            bottom = 0;
          };
        };

      };

      hyprland = {
        border-size = 3;
        gaps-in = 10;
        gaps-out = 10 * 2;
        active-opacity = 0.96;
        inactive-opacity = 0.92;
        blur = true;
        shadow = true;
        animation-speed = "fast"; # "fast" | "medium" | "slow"
        bar = {
          transparentButtons = false;
          floating = false;
          transparent = false;
          position = "top";
        };
      };
    };
    description = "Theme configuration options";
  };

  config.stylix = {
    enable = true;
    autoEnable = true;

    colorGeneration  = {
      scheme = "fruit-salad"; # options: "vibrant", "fruit-salad", "content",  "monochrome", "neutral", "rainbow", "tonal-spot"
      polarity = "dark";
      contrast = 0.0;
      lightness = {
        dark = -0.02;
        light = 0.0;
      };
    };

    opacity = {
      applications = 0.8;
      popups = 0.8;
      desktop = 0.8;
      terminal = 0.8;
    };

    cursor = {
      name = "phinger-cursors-light";
      package = pkgs.phinger-cursors;
      size = 20;
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrains Mono Nerd Font";
      };
      sansSerif = {
        package = pkgs.source-sans-pro;
        name = "Source Sans Pro";
      };
      serif = config.stylix.fonts.sansSerif;
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sizes = {
        applications = 13;
        desktop = 13;
        popups = 13;
        terminal = 13;
      };
    };

    # Sets Wallpaper
    # ----------------
    image = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/LuposX/nixos-config/master/ressources/wallpaper/impressionist-art-wallpapers.jpg";
        sha256 = "sha256-uYMTcF9jEj9LCftE4mzhibKqYhCFspjdH8JqwD4lbGs=";
    };
  };
}