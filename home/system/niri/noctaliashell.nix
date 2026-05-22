# For settings check out: https://github.com/noctalia-dev/noctalia-shell/blob/main/Assets/settings-default.json
# and: https://docs.noctalia.dev/v4/getting-started/nixos/
{
  inputs,
  config,
  ...
}:

let
  profilePicture = config.var.profile-picture;
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia-shell = {
    enable = true;

    plugins = {
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
}
