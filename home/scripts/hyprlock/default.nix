# - ## System
#-
#- Usefull quick scripts
#-
#- - `lock` - Lock the screen. (hyprlock)
{pkgs, ...}: let
  lock =
    pkgs.writeShellScriptBin "lock"
    # bash
    ''
      ${pkgs.hyprlock}/bin/hyprlock
    '';
in {home.packages = [lock];}
