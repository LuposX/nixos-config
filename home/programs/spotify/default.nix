# Spicetify is a spotify GUI client customizer
# spotify-player is a TUI client managed via the home-manager module below
{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  accent = "${config.lib.stylix.colors.base0D}";
  background = "${config.lib.stylix.colors.base00}";
in {
  imports = [inputs.spicetify-nix.homeManagerModules.default];

  # stylix.targets.spicetify.enable = true;

  # Force XWayland for Spotify — its Electron/CEF doesn't handle Wayland Ozone
  programs.spicetify = {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      playlistIcons
      lastfm
      historyShortcut
      hidePodcasts
      adblock
      fullAppDisplay
      keyboardShortcut
      shuffle
      songStats
      history
      betterGenres
    ];
  };

  # Override desktop entry to unset NIXOS_OZONE_WL so Spotify's old CEF
  # doesn't get --ozone-platform=wayland flags that cause silent crashes
  xdg.desktopEntries = {
    "spotify" = {
      name = "Spotify";
      exec = "env NIXOS_OZONE_WL=\"\" spotify %U";
      type = "Application";
      categories = [ "Audio" "Music" "Player" ];
      mimeType = [ "x-scheme-handler/spotify" ];
      terminal = false;
    };
  };

  programs.spotify-player = {
    enable = true;

    settings = {
      # --- General ---
      client_port = 8080;
      tracks_playback_limit = 100;
      default_device = "spotify-player";

      # --- Playback ---
      playback_format = "{status} {track} • {artists} {liked}\n{album} • {genres}\n{metadata}";
      playback_metadata_fields = ["repeat" "shuffle" "volume" "device" "progress"];
      seek_duration_secs = 5;

      # --- UI ---
      app_refresh_duration_in_ms = 32;
      playback_refresh_duration_in_ms = 250;
      page_size_in_rows = 30;
      border_type = "Rounded";
      progress_bar_type = "Line";
      progress_bar_position = "Bottom";
      genre_num = 3;
      custom_queue = true;

      # --- Notifications ---
      enable_notify = true;
      enable_media_control = true;

      # --- Cover Art ---
      enable_cover_image_cache = true;
      cover_img_length = 9;
      cover_img_width = 5;

      # --- Icons ---
      play_icon = "▶";
      pause_icon = "▐▐";
      liked_icon = "♥";
      explicit_icon = "🅴";

      # --- Device Config ---
      device = {
        name = "spotify-player";
        device_type = "computer";
        volume = 65;
        bitrate = 320;
        normalization = true;
        autoplay = true;
        audio_cache = false;
      };

      # --- Layout ---
      layout = {
        library = {
          playlist_percent = 35;
          album_percent = 35;
        };
        playback_window_position = "Top";
        playback_window_height = 6;
      };
    };
  };
}
