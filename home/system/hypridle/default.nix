# Hypridle is a daemon that listens for user activity and runs commands when the user is idle.
{
  pkgs,
  lib,
  config,
  ...
}: let
  isLaptop = config.var.isLaptop;
in {
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        ignore_dbus_inhibit = false;
        lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = ''
          hyprctl dispatch dpms on
          "${pkgs.brightnessctl}/bin/brightnessctl -r"}
        '';
      };

      listener = if isLaptop then [
        # Screen dim
        {
          timeout = 150;
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -r";
        }

        # Keyboard backlight dim
        {
          timeout = 150;
          on-timeout = "${pkgs.brightnessctl}/bin/brightnessctl -sd rgb:kbd_backlight set 0";
          on-resume = "${pkgs.brightnessctl}/bin/brightnessctl -rd rgb:kbd_backlight";
        }

        # Lock screen
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }

        # Turn screen off
        {
          timeout = 330;
          on-timeout = "$hyprctl dispatch dpms off";
          on-resume = ''
            hyprctl dispatch dpms on
            ${pkgs.brightnessctl}/bin/brightnessctl -r
          '';
        }

        # Suspend
        {
          timeout = 1200;
          on-timeout = "systemctl suspend";
        }
      ] else [
        # Desktop: Lock after 10 min
        {
          timeout = 600;
          on-timeout = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
        }

        # Desktop: Screen off at 11 min
        {
          timeout = 660;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "$hyprctl dispatch dpms on";
        }

        # Desktop: Suspend at 30 min
        {
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  systemd.user.services.hypridle.Unit.After = lib.mkForce "graphical-session.target";
}
