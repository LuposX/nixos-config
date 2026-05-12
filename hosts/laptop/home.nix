{
  pkgs,
  pkgsStable,
  config,
  inputs,
  ...
}: {
  imports = [
    # User-specific Configurations
    ./variables.nix

    # Programs
    ../../home/programs/ghosty
    ../../home/programs/kitty
    ../../home/programs/shell
    ../../home/programs/firefox
    ../../home/programs/git
    ../../home/programs/lazygit
    ../../home/programs/thunar
    ../../home/programs/vscode
    ../../home/programs/zathura
    ../../home/programs/ssh
    ../../home/programs/spotify
    ../../home/programs/thunderbird
    #  ../../home/programs/tailscale
    # ../../home/programs/anyrun
    # ../../home/programs/nvf
    ../../home/programs/nnn
    ../../home/programs/zen
    ../../home/programs/misc
    ../../home/programs/nvix

    # Scripts
    ../../home/scripts # All scripts

    # System
    ../../home/system/wofi
    ../../home/system/niri
    #../../home/system/hyprpanel
    #../../home/system/hyprland
    #../../home/system/hyprpaper
    ../../home/system/mime
    #../../home/system/hyprlock
    # ../../home/system/swayidle
    ../../home/system/udiskie
    # ../../home/system/clipman # Switched to Niri with wl-paste

    ./secrets # CHANGEME: You should probably remove this line, this is where I store my secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages =
      # UNSTABLE (system / fast-moving / dev / wayland)
      (with pkgs; [
        # Apps
        gnome-calendar
        resources
        gnome-clocks
        wireguard-ui
        zotero
        steam-run

        # Dev
        uv

        # Utils
        zip
        unzip
        pfetch
        fastfetch
        cliphist # For clipboard history in Noctalia

        # Key Stuff
        gnupg
        pinentry-curses

        # Fun
        peaclock
        cbonsai
        pipes
        cmatrix

        # Games
        adwaita-icon-theme
      ])

      # STABLE (big / heavy / slow-moving GUI apps)
      ++ (with pkgsStable; [
        libreoffice
        jetbrains.pycharm-community
        qbittorrent
        lutris
        gnome-text-editor
      ]);

    # Don't touch this
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
