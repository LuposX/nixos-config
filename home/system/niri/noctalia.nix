# Noctalia v5: native C++/OpenGL ES shell (no quickshell). Config is TOML,
# written to ~/.config/noctalia/config.toml by the home module. Settings docs:
# https://docs.noctalia.dev/noctalia/configuration/
# The module validates the config at build time with `noctalia config validate`
# (checkConfig, on by default).
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  # Local v5 plugin (port of the v4 mirror-mirror wl-mirror plugin), built as
  # a static plugin dir and registered as a read-only `path` source below.
  mirrorMirrorPlugin = pkgs.callPackage ./noctalia-plugins/mirror-mirror/default.nix {};
in {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    # The module defaults the package to the flake's own build (pinned to the
    # cachix branch in flake.nix), so no overlay or package override needed.

    settings = {
      shell = {
        avatar_path = config.var.profile-picture;
        clipboard_enabled = true; # v4: appLauncher.enableClipboardHistory
      };

      lockscreen.blur_intensity = 0.7; # v4: general.lockScreenBlur

      # v4 idle timers carried over as named behaviors. Screen-off and lock
      # are host-dependent: desktop 10 min screen-off / 15 min lock, laptop
      # 2.5 min / 5 min to save battery. Suspend after 20 min.
      idle = {
        pre_action_fade_seconds = 3.0; # v4: idle.fadeDuration
        behavior = {
          screen-off = {
            timeout =
              if config.var.isLaptop
              then 150
              else 600;
            action = "screen_off";
            enabled = true;
          };
          lock = {
            timeout =
              if config.var.isLaptop
              then 300
              else 900;
            action = "lock";
            enabled = true;
          };
          suspend = {
            timeout = 1200;
            action = "suspend";
            enabled = true;
          };
        };
      };

      # v4: location.name. Feeds weather, night light, and theme auto mode.
      location.address = config.var.location;

      weather.unit = "celsius"; # v4: location.useFahrenheit = false

      # Same wallpaper stylix pins for the whole system, so both stay in sync.
      # NOTE: v5's state file (~/.local/state/noctalia/settings.toml) beats
      # this block; if the wallpaper was changed via the Settings UI, delete
      # the [wallpaper.*] tables there to let the declarative path win.
      wallpaper = {
        enabled = true;
        default.path = config.stylix.image;
      };

      # Local v5 plugin (port of the v4 mirror-mirror wl-mirror plugin),
      # built as a static dir and registered as a read-only `path` source.
      # `enabled` is declarative-friendly user intent; the shell merges it
      # with its own runtime toggles.
      plugins = {
        enabled = ["monkeman/mirror-mirror"];
        source = [
          {
            name = "nix";
            kind = "path";
            location = mirrorMirrorPlugin;
            enabled = true;
          }
        ];
      };

      # v4 "simple" bar look: full-bleed edge-to-edge strip that pushes
      # windows away instead of overlaying them, with widgets flush against
      # the screen corners.
      bar.main = {
        position = "top";
        font_scale = 1.2; # v4: bar.fontScale
        margin_ends = 0; # no inset from the left/right screen edges
        margin_edge = 0; # flush against the top edge, no floating gap
        radius = 0; # square corners (floating-bar radius makes no sense here)
        reserve_space = true; # compositor exclusive zone: no window overlap
        padding = 0; # widget sections start at the very left / very right
        start = ["launcher" "clock" "sysmon" "active_window"];
        center = ["workspaces" "media"];
        end = [
          "tray"
          "notifications"
          "keyboard_layout"
          "volume"
          "battery"
          "monkeman/mirror-mirror:toggle"
          "control-center"
        ];
      };

      # v4: Clock format "HH:mm ddd, MMM dd". v5 dropped the monospaced-font
      # toggle; if the proportional digits bother you, set font_family here.
      widget.clock.format = "{:%H:%M %a, %b %d}";

      # v4: Workspace widget (labelMode = "index", hideUnoccupied = false).
      widget.workspaces = {
        label_source = "id";
        hide_when_empty = false;
      };

      # v4 tray behavior: icons collapsed behind a chevron button instead of
      # inline (netbird, blueman, …). Right-click an item in the drawer and
      # use Pin/Unpin to keep one permanently visible (writes [widget.tray].pinned).
      widget.tray.drawer = true;

      # v4: Battery displayMode = "alwaysShow" is v5's default behavior.
      theme = {
        source = "wallpaper"; # palette generated from the wallpaper (as in v4)
        wallpaper_scheme = "fruit-salad"; # matches the stylix color scheme
      };
    };

    # Plugin notes (v5 plugins are Luau; QML plugins from v4 do not carry
    # over):
    #   - niri-layout-indicator is gone: v5 has a built-in keyboard_layout
    #     bar widget, enabled in bar.main.end above.
    #   - mirror-mirror is ported as a local plugin in ./noctalia-plugins/
    #     (mirror one monitor to another with wl-mirror); registered under
    #     settings.plugins above.
  };
}
