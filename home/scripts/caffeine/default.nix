# - ## Caffeine
#-
#- Caffeine is a simple script that toggles idle inhibition (disable suspend & screenlock).
#-
#- Since switching to niri + Noctalia, idle is handled by the Noctalia shell.
#- Noctalia v5 has native caffeine support (caffeine-enable/disable IPC with
#- its own OSD), so this script is now a thin wrapper around that.
#-
#- State is still tracked in $XDG_CACHE_HOME/caffeine for caffeine-status /
#- caffeine-status-icon, because v5 has no status query IPC. Caveat: v5's
#- built-in caffeine widget and `caffeine-toggle` bypass this file, so mixing
#- them desyncs the status scripts; prefer this wrapper or the widget, not both.
#-
#- - `caffeine-status` - Check if idle inhibition is active. (0/1)
#- - `caffeine-status-icon` - Check if idle inhibition is active. (icon)
#- - `caffeine` - Toggle idle inhibition.
#
# Source: https://github.com/anotherhadi/nixy/blob/main/home/scripts/caffeine/default.nix
# (adapted to Noctalia v5 caffeine IPC)
{pkgs, ...}: let
  stateFile = "\${XDG_CACHE_HOME:-$HOME/.cache}/caffeine";
in {
  home.packages = [
    (pkgs.writeShellScriptBin "caffeine-status" ''
      [[ "$(cat ${stateFile} 2>/dev/null)" == "1" ]] && echo "1" || echo "0"
    '')

    (pkgs.writeShellScriptBin "caffeine-status-icon" ''
      if [[ "$(cat ${stateFile} 2>/dev/null)" == "1" ]]; then
        echo "󰅶"
      else
        echo "󰾪"
      fi
    '')

    (pkgs.writeShellScriptBin "caffeine" ''
      if [[ "$(cat ${stateFile} 2>/dev/null)" == "1" ]]; then
        noctalia msg caffeine-disable >/dev/null 2>&1
        echo "0" > ${stateFile}
      else
        noctalia msg caffeine-enable >/dev/null 2>&1
        echo "1" > ${stateFile}
      fi
    '')
  ];}
