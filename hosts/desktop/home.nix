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
    # ../../home/programs/nvf
    ../../home/programs/nnn

    # Scripts
    ../../home/scripts # All scripts

    # System
    ../../home/system/wofi
    ../../home/system/hyprpanel
    ../../home/system/hyprland
    ../../home/system/hyprpaper
    ../../home/system/mime
    ../../home/system/hyprlock
    ../../home/system/hypridle
    ../../home/system/udiskie
    ../../home/system/clipman

    ./secrets # CHANGEME: You should probably remove this line, this is where I store my secrets
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      inputs.nvix.packages.${pkgs.system}.core

      # Apps
      vlc # Video player
      gnome-calendar # Calendar
      textpieces # Manipulate texts
      resources # Monitor for your system resources
      gnome-clocks
      gnome-text-editor
      mpv # Video player
      libreoffice-qt6 # Office Stuff
      popsicle
      anki

      # Dev
      python3

      # Utils
      zip
      unzip
      btop
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
