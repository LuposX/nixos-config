{
  pkgs,
  ...
}:
{
  programs.niri = {
    enable = true;
    package = pkgs.niri;
    settings = {
      prefer-no-csd = true;

      hotkey-overlay = {
        skip-at-startup = true;
      };

      overview = {
        workspace-shadow.enable = false;
      };

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

      outputs = {
        "eDP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.000;
          };
          scale = 1.0;
          position = {
            x = 0;
            y = 0;
          };
          variable-refresh-rate = true; # on-demand=true
          focus-at-startup = true;
        };
      };

      input = {
        keyboard.xkb.layout = "de";
        touchpad = {
          click-method = "button-areas";
          dwt = true;
          dwtp = true;
          natural-scroll = false;
          scroll-method = "two-finger";
          tap = true;
          tap-button-map = "left-right-middle";
          middle-emulation = true;
          accel-speed = 0.65;
        };
        focus-follows-mouse.enable = true;
        warp-mouse-to-focus.enable = false;
      };

      environment = {
        CLUTTER_BACKEND = "wayland";
        GDK_BACKEND = "wayland,x11";
        MOZ_ENABLE_WAYLAND = "1";
        NIXOS_OZONE_WL = "1";
        ANKI_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";

        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "niri";
        DISPLAY = ":0";
      };
    };
  };
}
