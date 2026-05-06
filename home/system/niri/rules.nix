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
        open-on-workspace = "music";
      }
      {
        matches = [
          { title = "Cider"; }
        ];
        open-on-workspace = "music";
      }

      {
        matches = [ { } ];
        geometry-corner-radius = {
          top-left = 20.0;
          top-right = 20.0;
          bottom-left = 20.0;
          bottom-right = 20.0;
        };
        clip-to-geometry = true;
      }
    ];
  };
}
