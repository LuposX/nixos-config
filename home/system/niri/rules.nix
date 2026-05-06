{
  ...
}:

{
  programs.niri.settings = {
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
      # Browsers
      # {
      #   matches = [
      #     { app-id = "firefox"; }
      #   ];
      #   open-on-workspace = "browser";
      # }
      # {
      #   matches = [
      #     { app-id = "zen"; }
      #   ];
      #   open-on-workspace = "browser";
      # }

      # Music
      {
        matches = [
          { title = "spotify_player"; }
        ];
        open-on-workspace = "4";
      }
      {
        matches = [
          { title = "Cider"; }
        ];
        open-on-workspace = "4";
      }

      {
        matches = [
          { app-id = "zen"; }
        ];
        open-on-workspace = "1";
      }

      {
        matches = [
          { app-id = "kitty"; }
        ];
        open-on-workspace = "2";
      }

      {
        matches = [
          { app-id = "blueman-manager"; }
        ];
        floating = true;
        center = true;
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
