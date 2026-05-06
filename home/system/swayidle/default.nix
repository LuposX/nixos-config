# Swayidle is a user idle manager compatible with Wayland sessions.
{
  pkgs,
  lib,
  config,
  ...
}: let
  isLaptop = config.var.isLaptop;
  execStart = if isLaptop then ''
    ${pkgs.swayidle}/bin/swayidle \
      timeout 150 '${pkgs.brightnessctl}/bin/brightnessctl -s set 10' '${pkgs.brightnessctl}/bin/brightnessctl -r' \
      timeout 300 'loginctl lock-session' \
      timeout 330 'hyprctl dispatch dpms off' 'hyprctl dispatch dpms on; ${pkgs.brightnessctl}/bin/brightnessctl -r' \
      timeout 1200 'systemctl suspend'
  '' else ''
    ${pkgs.swayidle}/bin/swayidle \
      timeout 600 'pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock' \
      timeout 660 '${pkgs.brightnessctl}/bin/brightnessctl -s set 10' '${pkgs.brightnessctl}/bin/brightnessctl -r' \
      timeout 1800 'systemctl suspend'
  '';
in {
  home.packages = [ pkgs.swayidle pkgs.brightnessctl ];

  systemd.user.services.swayidle = {
    Unit = {
      After = "graphical-session.target";
      Wants = "graphical-session.target";
    };
    Service = {
      ExecStart = execStart;
      Restart = "always";
      RestartSec = "10s";
      KillMode = "process";
    };
  };
}
