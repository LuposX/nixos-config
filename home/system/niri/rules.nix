{
  ...
}:

{
  programs.niri.settings = {
    workspaces = {
      "01-browser" = { name = "browser"; };
      "02-terminal" = { name = "terminal"; };
      "03-music" = { name = "music"; };
    };

    layer-rules = [
      {
        # Set the overview wallpaper on the backdrop
        matches = [
          {
            namespace = "^noctalia-wallpaper*";
          }
        ];
        place-within-backdrop = true;
      }
    ];

    window-rules = [
      {
        matches = [
          { app-id = "spotify"; at-startup = true; }
        ];
        open-on-workspace = "music";
      }

      {
        matches = [
          { app-id = "zen-twilight"; at-startup = true; }
        ];
        open-on-workspace = "browser";
      }

      {
        matches = [
          { app-id = "kitty"; at-startup = true; }
        ];
        open-on-workspace = "terminal";
      }

      {
        matches = [
          { app-id = "ghostty"; at-startup = true; }
        ];
        open-on-workspace = "terminal";
      }

      {
        matches = [
          { app-id = "blueman-manager"; }
        ];
        open-on-workspace = "music";
      }

      {
        matches = [ { } ];
        geometry-corner-radius = {
          top-left = 4.0;
          top-right = 4.0;
          bottom-left = 4.0;
          bottom-right = 4.0;
        };
        clip-to-geometry = true;
      }
    ];
  };
}
