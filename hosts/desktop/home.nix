{
  pkgs,
  config,
  ...
}: {
  imports = [
    # User-specific Configurations
    ./variables.nix

    # Programs
    ../../home/programs/kitty
    ../../home/programs/shell
    ../../home/programs/firefox
    ../../home/programs/nvf
    ../../home/programs/git
    ../../home/programs/lazygit
    # ../../home/programs/anyrun
    ../../home/programs/thunar
    ../../home/programs/vscode

    # Scripts
    ../../home/scripts # All scripts

    # System
    ../../home/system/wofi
    ../../home/system/hyprpanel
    ../../home/system/hyprland
  ];

  home = {
    inherit (config.var) username;
    homeDirectory = "/home/" + config.var.username;

    packages = with pkgs; [
      # Apps
      vlc # Video player
      gnome-calendar # Calendar
      textpieces # Manipulate texts
      resources # Monitor for your system resources
      gnome-clocks
      gnome-text-editor
      mpv # Video player
            
      # Dev
      python3

      # Utils
      zip
      unzip
      btop
      pfetch
      fastfetch

      # Fun
      peaclock
      cbonsai
      pipes
      cmatrix
    ];

    # Don't touch this
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}
