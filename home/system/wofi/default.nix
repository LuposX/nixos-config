# Wofi is a launcher for Wayland, inspired by rofi.
{
  config,
  pkgs,
  lib,
  ...
}: let
  #accent = "#${config.lib.stylix.colors.base0D}";
  #background = "#${config.lib.stylix.colors.base00}";
  #background-alt = "#${config.lib.stylix.colors.base01}";
  #foreground = "#${config.lib.stylix.colors.base05}";
  #font = config.stylix.fonts.serif.name;
  #rounding = config.theme.rounding;
  #font-size = config.stylix.fonts.sizes.popups;
  accent = "#88C0D0"; # Soft cyan (accent)
  background = "#2E3440"; # Dark grey-blue background
  background-alt = "#3B4252"; # Slightly lighter background (e.g., hover)
  foreground = "#ECEFF4"; # Almost white text
  font = "Inter"; # You can also try FiraCode, Iosevka, or Inter
  rounding = 10; # Rounded corners in pixels
  font-size = 14; # Font size in px or pt depending on context
in {
  home.packages = with pkgs; [wofi-emoji];

  programs.wofi = {
    enable = true;

    settings = {
      term = "kitty";
      terminal = "kitty";
      allow_markup = true;
      width = 650;
      show = "drun";
      prompt = "Apps";
      normal_window = true;
      layer = "top";
      height = "325px";
      orientation = "vertical";
      halign = "fill";
      line_wrap = "off";
      dynamic_lines = false;
      allow_images = true;
      image_size = 24;
      exec_search = false;
      hide_search = false;
      parse_search = false;
      insensitive = true;
      hide_scroll = true;
      no_actions = true;
      sort_order = "default";
      gtk_dark = true;
      filter_rate = 100;
      key_expand = "Tab";
      key_exit = "Escape";
    };

    style =
      lib.mkForce
      # css
      ''
        * {
          font-family: "${font}";
          font-weight: 600;
          font-size: ${toString font-size}px;
        }

        #window {
          background-color: ${background};
          color: ${foreground};
          border-radius: ${toString rounding}px;
        }

        #outer-box {
          padding: 20px;
        }

        #input {
          background-color: ${background-alt};
          border: 0px solid ${accent};
          color: ${foreground};
          padding: 8px 12px;
        }

        #scroll {
          margin-top: 20px;
        }

        #inner-box {}

        #img {
          padding-right: 8px;
        }

        #text {
          color: ${foreground};
        }

        #text:selected {
          color: ${foreground};
        }

        #entry {
          padding: 6px;
        }

        #entry:selected {
          background-color: ${accent};
          color: ${foreground};
        }

        #unselected {}

        #selected {}

        #input,
        #entry:selected {
          border-radius: ${toString rounding}px;
        }
      '';
  };
}
