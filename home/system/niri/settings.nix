{
  pkgs,
  config,
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
        workspace-shadow.enable = true;
      };

      layout = {
        background-color = config.theme.niri.layout."background-color";

        focus-ring = {
          enable = config.theme.niri.layout."focus-ring".enable;
          width = config.theme.niri.layout."focus-ring".width;
          active = {
            color = config.theme.niri.layout."focus-ring".active.color;
          };
          inactive = {
            color = config.theme.niri.layout."focus-ring".inactive.color;
          };
        };

        gaps = config.theme.niri.layout.gaps;

        struts = {
          left = config.theme.niri.layout.struts.left;
          right = config.theme.niri.layout.struts.right;
          top = config.theme.niri.layout.struts.top;
          bottom = config.theme.niri.layout.struts.bottom;
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
        keyboard.xkb.layout = config.var.keyboardLayout;
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
        focus-follows-mouse.enable = false;
        warp-mouse-to-focus.enable = true;
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
