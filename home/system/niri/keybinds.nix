{
  config,
  pkgs,
  ...
}:

let
  apps = import ./applications.nix { inherit pkgs; };

  noctalia =
    cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);
in
{
  programs.niri.settings.binds = with config.lib.niri.actions; {
    # Hardware Keys - Volume
    "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase"; # output increase
    "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease"; # output decrease
    "XF86AudioMute".action.spawn = noctalia "volume muteOutput"; # output mute
    "shift+XF86AudioRaiseVolume".action.spawn = noctalia "volume increaseInput"; # input increase
    "shift+XF86AudioLowerVolume".action.spawn = noctalia "volume decreaseInput"; # input decrease
    "shift+XF86AudioMute".action.spawn = noctalia "volume muteInput"; # input mute
    "control+XF86AudioMute".action.spawn = noctalia "volume togglePanel"; # open volume panel

    # Hardware Keys - Media
    "XF86AudioPlay".action.spawn = noctalia "media playPause";
    "XF86AudioNext".action.spawn = noctalia "media next";
    "XF86AudioPrev".action.spawn = noctalia "media previous";

    # Hardware Keys - Brightness
    "XF86MonBrightnessUp".action.spawn = ["brightnessctl" "set" "+10%"];
    "XF86MonBrightnessDown".action.spawn = ["brightnessctl" "set" "10%-"];

    # Applications
    "super+space".action.spawn = noctalia "launcher toggle";
    "super+return".action = spawn apps.terminal;
    "super+b".action = spawn apps.browser;
    "super+e".action = spawn apps.fileManager;

    # Search and Open Files
    "super+s".action = spawn ["wofi" "--show=drun" "--width=900" "--height=600"];

    # Grep and Open Files (uses fzf)
    "super+g".action = spawn ["bash" "-c" "find /home -type f 2>/dev/null | fzf | xargs -r xdg-open"];


    # Window Management
    "super+q".action = close-window;
    "super+f".action = fullscreen-window;
    "super+t".action = toggle-window-floating;

    # Screenshots
    "super+p".action = screenshot;  # Screenshot current screen
    "super+shift+p".action.screenshot-window = [ ];  # Screenshot active window
    "control+shift+p".action.screenshot = [ ];  # Screenshot region
    "alt+control+p".action = spawn ["bash" "-c" "'${pkgs.grim}/bin/grim -g \"\\$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.swappy}/bin/swappy -f -'"];  # Screenshot region + edit (Swappy)

    # Focus Navigation
    "super+left".action = focus-column-left;
    "super+right".action = focus-column-right;
    "super+up".action = focus-workspace-up;
    "super+down".action = focus-workspace-down;

    # Window Movement (Master/Tile layout)
    "super+shift+left".action = move-column-left;
    "super+shift+right".action = move-column-right;
    "super+shift+up".action = move-column-to-workspace-up;
    "super+shift+down".action = move-column-to-workspace-down;

    # Workspace Management (1-4)
    "super+1".action = focus-workspace "1";
    "super+2".action = focus-workspace "2";
    "super+3".action = focus-workspace "3";
    "super+4".action = focus-workspace "4";

    # Move window to workspace
    "super+shift+1" = { action.move-window-to-workspace = "1"; };
    "super+shift+2" = { action.move-window-to-workspace = "2"; };
    "super+shift+3" = { action.move-window-to-workspace = "3"; };
    "super+shift+4" = { action.move-window-to-workspace = "4"; };

    # Lock Screen
    "super+l".action.spawn = noctalia "lockScreen lock";

    # Clipboard picker
    "shift+super+c".action = spawn [
      "${pkgs.wofi}/bin/wofi"
      "--show=clipboard"
      "-p" "Clipboard: "
    ];

    # Emoji picker
    "shift+super+e".action = spawn [
      "${pkgs.wofi-emoji}/bin/wofi-emoji"
      "-p" "Emoji: "
    ];
  };
}
