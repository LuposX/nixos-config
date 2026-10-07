# - ## Caffeine
#-
#- Caffeine is a simple script that toggles idle inhibition (disable suspend & screenlock).
#-
#- Since switching to niri + Noctalia, idle is handled by the Noctalia shell
#- (idleInhibitor IPC), so this script talks to that instead of swayidle.
#-
#- State is tracked in $XDG_CACHE_HOME/caffeine, because Noctalia v4 has no
#- status IPC for the inhibitor. Caveat: toggling via a KeepAwake bar widget
#- (if one is ever added) would desync the icon.
#-
#- - `caffeine-status` - Check if idle inhibition is active. (0/1)
#- - `caffeine-status-icon` - Check if idle inhibition is active. (icon)
#- - `caffeine` - Toggle idle inhibition.
#
# Source: https://github.com/anotherhadi/nixy/blob/main/home/scripts/caffeine/default.nix
# (adapted from swayidle to Noctalia idleInhibitor)
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
      toast() {
        # Fire-and-forget; only works while the Noctalia shell is running.
        noctalia-shell ipc call toast send "$1" >/dev/null 2>&1
      }

      if [[ "$(cat ${stateFile} 2>/dev/null)" == "1" ]]; then
        noctalia-shell ipc call idleInhibitor disable >/dev/null 2>&1
        echo "0" > ${stateFile}
        toast '{"title": "Caffeine Off", "body": "Idle actions enabled", "icon": "coffee-off"}'
      else
        noctalia-shell ipc call idleInhibitor enable >/dev/null 2>&1
        echo "1" > ${stateFile}
        toast '{"title": "Caffeine On", "body": "Idle actions inhibited", "icon": "coffee"}'
      fi
    '')
  ];}