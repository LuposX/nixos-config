# For settings check out: https://github.com/noctalia-dev/noctalia-shell/blob/main/Assets/settings-default.json
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

    settings = {
      bar = {
        density = "compact";
        position = "top";
        barType = "simple";
        showCapsule = false;
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
              id = "MediaMini";
            }
          ];
          center = [
            {
              id = "Workspace";
              hideUnoccupied = false;
              labelMode = "index";
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

      colorSchemes.predefinedScheme = "Catppuccin-Lavender";

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
