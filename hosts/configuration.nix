
{ config, lib, pkgs, inputs, vars, ... }:

let
  terminal = pkgs.${vars.terminal};
in
{  
  imports = [
    ../modules/default.nix
  ];
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${vars.user} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "lp" "scanner"];
    initialPassword = "password"; # Change this password after installation
  };
  
  # When run in a VM
  virtualisation.virtualbox.guest.enable = true;
  hardware.graphics.enable = true;  
  
  xdg.portal = {
    enable = true;  
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "de";

  security = {
    sudo.wheelNeedsPassword = false; # Sudo doesn't need password
    rtkit.enable = true; # For audio
    polkit.enable = true; # Managing permissions
  };
  
  fonts.packages = with pkgs; [
     jetbrains-mono
     font-awesome
     noto-fonts
     noto-fonts-cjk-sans
     noto-fonts-emoji
     # For Nerdfonts
     (nerdfonts.override {
     fonts = [
       "FiraCode"
       "NerdFontsSymbolsOnly"
     ];
    })
  ];

  environment = {
    variables = {
      TERMINAL = "${vars.terminal}";
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };
  };
  
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Terminal
    git 
    wget
    btop
    vim
    pciutils
    usbutils
    coreutils
    lshw
    xdg-utils
    terminal
    fastfetch
    kitty
    hostname
    fiche # Allows to upload text to pastebin from terminal
    # Usage: cat file.txt | nc termbin.com 9999   
    playerctl # for media play
    alacritty
    # clipboard-jh # copying wayland    
    cliphist

    # Apps
    mpv
    feh
    image-roll
    firefox 
    thunderbird

    # File Managment
    unzip
    unrar
    file-roller 
    rsync
    
    # Office
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.de_DE
  ];

  # Thunar
  programs.thunar.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # SSH
  services.openssh = {
    enable = true;
    ports = [22];
  };
  networking.firewall.allowedTCPPorts = [ 22 ];  

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Networking
  # networking.useDHCP = true;
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  # Flatpaks
  services.flatpak.enable = true;
   
  # Enabling Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Optimizes Storage, more space, yipee
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Automatic updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates="weekly";
  };
  
  # DO NOT CHANGE, If you want to upgrade use CLI.
  system.stateVersion = "24.05";    

  home-manager.users.${vars.user} = {
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;
    
    # Default applications
    xdg = {
      mime.enable = true;
      # Only set default applications if not gnome.
      mimeApps =  {
        enable = true;
        defaultApplications = {
          "image/jpeg" = [ "image-roll.desktop" "feh.desktop" ];
          "image/png" = [ "image-roll.desktop" "feh.desktop" ];
          "text/plain" = "nvim.desktop";
          "text/html" = "nvim.desktop";
          "text/csv" = "nvim.desktop";
          "application/pdf" = [ "firefox.desktop" ];
          "application/zip" = "org.gnome.FileRoller.desktop";
          "application/x-tar" = "org.gnome.FileRoller.desktop";
          "application/x-bzip2" = "org.gnome.FileRoller.desktop";
          "application/x-gzip" = "org.gnome.FileRoller.desktop";
          "x-scheme-handler/http" = [ "firefox.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" ];
          "x-scheme-handler/about" = [ "firefox.desktop" ];
          "x-scheme-handler/unknown" = [ "firefox.desktop"  ];
          "x-scheme-handler/mailto" = [ "thunderbird.desktop" ];
          "audio/mp3" = "mpv.desktop";
          "audio/x-matroska" = "mpv.desktop";
          "video/webm" = "mpv.desktop";
          "video/mp4" = "mpv.desktop";
          "video/x-matroska" = "mpv.desktop";
          "inode/directory" = "thunar.desktop";
        };
      };
    };
  };
}
