{
  pkgs,
  config,
  inputs,
  ...
}: {
  imports = [
    # User-specific Configurations
    ./variables.nix

    # Programs
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
    # ../../home/programs/tailscale
    # ../../home/programs/anyrun
    ../../home/programs/nvf
    ../../home/programs/nnn
    ../../home/programs/zen
    ../../home/programs/misc
    # ../../home/programs/nvix

    # Scripts
    ../../home/scripts # All scripts

    # System
    ../../home/system/wofi
    # ../../home/system/hyprpanel  # Switched to Niri with Noctalia
    # ../../home/system/hyprland  # Switched to Niri
    # ../../home/system/hyprpaper  # Switched to Niri
    ../../home/system/niri
    ../../home/system/mime
    # ../../home/system/hyprlock  # Switched to Niri
    # ../../home/system/hypridle  # Switched to Niri
    ../../home/system/udiskie
    # ../../home/system/clipman # Switched to Niri with wl-paste

    ./secrets # CHANGEME: You should probably remove this line, this is where I store my secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [

      # Apps
      gnome-calendar # Calendar
      resources # Monitor for your system resources
      gnome-clocks
      libreoffice-qt6 # Office Stuff
      popsicle
      tor
      tor-browser
      ledger-udev-rules
      ledger-live-desktop
      kdePackages.kleopatra
      zotero
      telegram-desktop

      # Dev
      uv
      reptyr

      # Utils
      zip
      unzip
      pfetch
      fastfetch

      # Key Stuff
      gnupg
      pinentry-curses

      # Fun
      peaclock
      cbonsai
      pipes
      cmatrix

      # Spyware, use web-client.
      # zoom-us
    ];

    # Don't touch this
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
