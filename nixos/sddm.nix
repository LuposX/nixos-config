# SDDM configuration without Stylix
{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  # Define your static color palette
  foreground = "e0def4"; # a soft light color, tweak to your liking

  # Optionally choose one background image manually
  backgroundUrl = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/anotherhadi/nixy-wallpapers/refs/heads/main/wallpapers/studio.gif";
    sha256 = "sha256-qySDskjmFYt+ncslpbz0BfXiWm4hmFf5GPWF2NlTVB8=";
  };

  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
    themeConfig = {
      Background = backgroundUrl;
      HeaderTextColor = "#${foreground}";
      DateTextColor = "#${foreground}";
      TimeTextColor = "#${foreground}";
      LoginFieldTextColor = "#${foreground}";
      PasswordFieldTextColor = "#${foreground}";
      UserIconColor = "#${foreground}";
      PasswordIconColor = "#${foreground}";
      WarningColor = "#${foreground}";
      LoginButtonBackgroundColor = "#${foreground}";
      SystemButtonsIconsColor = "#${foreground}";
      SessionButtonTextColor = "#${foreground}";
      VirtualKeyboardButtonTextColor = "#${foreground}";
      DropdownBackgroundColor = "#${foreground}";
      HighlightBackgroundColor = "#${foreground}";
    };
  };
in {
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      package = pkgs.kdePackages.sddm;
      extraPackages = [sddm-astronaut];
      theme = "sddm-astronaut-theme";
      settings = {
        Wayland.SessionDir = "${inputs.hyprland.packages."${pkgs.system}".hyprland}/share/wayland-sessions";
      };
    };
  };

  environment.systemPackages = [sddm-astronaut];

  # Prevent shutdown hang
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
