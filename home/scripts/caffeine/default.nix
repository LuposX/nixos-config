# - ## Caffeine
#-
#- Caffeine is a simple script that toggles swayidle (disable suspend & screenlock).
#-
#- - `caffeine-status` - Check if swayidle is running. (0/1)
#- - `caffeine-status-icon` - Check if swayidle is running. (icon)
#- - `caffeine` - Toggle swayidle.
#
# Source: https://github.com/anotherhadi/nixy/blob/main/home/scripts/caffeine/default.nix
{pkgs, ...}: let
  caffeine-status = pkgs.writeShellScriptBin "caffeine-status" ''
    [[ $(pidof "swayidle") ]] && echo "0" || echo "1"
  '';

  caffeine-status-icon = pkgs.writeShellScriptBin "caffeine-status-icon" ''
    [[ $(pidof "swayidle") ]] && echo "󰾪" || echo "󰅶"
  '';

  caffeine = pkgs.writeShellScriptBin "caffeine" ''
    if [[ $(pidof "swayidle") ]]; then
      systemctl --user stop swayidle.service
      ${pkgs.swayosd}/bin/swayosd-client --custom-message="Caffeine On" --custom-icon="emblem-default"
    else
      systemctl --user start swayidle.service
      ${pkgs.swayosd}/bin/swayosd-client --custom-message="Caffeine Off" --custom-icon="emblem-default"
    fi
  '';
in {home.packages = [caffeine-status caffeine caffeine-status-icon];}
