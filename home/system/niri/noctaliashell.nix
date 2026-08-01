# For settings check out: https://github.com/noctalia-dev/noctalia-shell/blob/main/Assets/settings-default.json
# and: https://docs.noctalia.dev/v4/getting-started/nixos/
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

let
  profilePicture = config.var.profile-picture;

  # Keyboard layout indicator for niri.
  # Vendored via home.activation (NOT the noctalia auto-installer): noctalia's
  # installer does `git sparse-checkout set <pluginId>` and expects the plugin
  # in an `<id>/` subdirectory, but this repo keeps manifest.json at the root.
  # A home.file symlink would be read-only and break plugin settings persistence
  # (~/.config/noctalia/plugins/<id>/settings.json), hence the mutable copy.
  niriLayoutIndicatorSrc = pkgs.fetchFromGitHub {
    owner = "alnrog";
    repo = "niri-layout-indicator";
    rev = "4600763d382b531bce5e55836258239b6f53a48b";
    hash = "sha256-a2LzkgrmClvW6K63NNTungPgN5B0twteLVo7v0tWljs=";
  };
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;

    plugins = {
      version = 2;
      sources = [
        {
          enabled = true;
          name = "Official Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];

      states = {
        mirror-mirror = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
        niri-layout-indicator = {
          enabled = true;
          # "local" because the plugin is vendored below (mirrors the upstream
          # install.sh which registers it with sourceUrl "local").
          sourceUrl = "local";
        };
      };
    };

    settings = {
      bar = {
        density = "default";
        position = "top";
        barType = "simple";
        showCapsule = false;
        fontScale = 1.2;
        widgets = {
          left = [
            {
              id = "Launcher";
            }
            {
              id = "Clock";
              formatHorizontal = "HH:mm ddd, MMM dd";
              formatVertical = "HH mm";
              useMonospacedFont = true;
              usePrimaryColor = false;
            }
            {
              id = "SystemMonitor";
            }
            {
              id = "ActiveWindow";
            }
            {
              id = "plugin:mirror-mirror";
            }
          ];
          center = [
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "index";
            }
            {
              id = "MediaMini";
            }
          ];
          right = [
            {
              id = "Tray";
            }
            {
              id = "NotificationHistory";
            }
            {
              id = "plugin:niri-layout-indicator";
            }
            {
              id = "Volume";
            }
            {
              id = "Battery";
              displayMode = "alwaysShow";
            }
            {
              id = "ControlCenter";
              useDistroLogo = false;
              avatarImage = profilePicture;
              icon = "noctalia"; # used when distro logo is set to false
              enableColorization = true;
            }
          ];
        };
      };

      general = {
        avatarImage = profilePicture;
        lockScreenBlur = 0.7;
      };

      idle = {
        enabled = true;
        screenOffTimeout = 150;
        lockTimeout = 300;
        suspendTimeout = 1200;
        fadeDuration = 3;
      };

      location = {
        analogClockInCalendar = true;
        name = config.var.location;
        useFahrenheit = false;
      };

      network = {

      };

      appLauncher = {
        enableClipboardHistory = true;
      };
    };
    # this may also be a string or a path to a JSON file.
  };

  # Deploy the vendored plugin as a mutable copy (see niriLayoutIndicatorSrc
  # above). Keeps the directory writable so noctalia can persist plugin
  # settings.json; settings.json is preserved across rebuilds (not in src).
  home.activation.installNiriLayoutIndicator = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/noctalia/plugins/niri-layout-indicator"
    cp -r ${niriLayoutIndicatorSrc}/. "$HOME/.config/noctalia/plugins/niri-layout-indicator/"
  '';
}
